//
//  ImageSearchView.swift
//  GestureApp
//
//  Created by Shraddha on 05/01/26.
//

import SwiftUI
import CoreML
import Vision

struct Product: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let image: UIImage
    let feature: VNFeaturePrintObservation
}


struct ImageSearchView: View {
    @State private var allProducts: [Product] = []
    @State private var selectedImage: UIImage?
    @State private var similarProducts: [Product] = []
    @State private var showImagePicker = false
    @State private var statusText = "Upload an image to find similar ones"
    @State private var selectedProduct: Product?
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Selected image display
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 280, maxHeight: 280)
                            .cornerRadius(16)
                            .shadow(radius: 6)
                            .padding(.top, 10)
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.15))
                            .frame(width: 280, height: 280)
                            .overlay(Text("No image selected").foregroundColor(.gray))
                    }
                    
                    Text(statusText)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: { showImagePicker.toggle() }) {
                        Label("Choose Image", systemImage: "photo.on.rectangle.angled")
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.trelleborgGold)
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(image: $selectedImage, onImagePicked: classifyAndCompare)
                    }
                    
                    // MARK: - Similar Images Section
                    if !similarProducts.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Similar Images")
                                .font(.title2)
                                .bold()
                                .padding(.leading)
                            
                            if similarProducts.count <= 3 {
                                // Horizontal layout for up to 3 images
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(similarProducts) { product in
                                            productItem(product)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            } else {
                                // Vertical grid layout for more than 3 images
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                    ForEach(similarProducts) { product in
                                        productItem(product)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 10)
                    }
                }
                .padding()
            }
            
            .onAppear(perform: loadProductDataset)
            //.onAppear(perform: loadProductDataset)
            .navigationDestination(item: $selectedProduct) { product in
                ProductDetailView(product: product)
            }
        }
    }
    
    
    @ViewBuilder
    private func productItem(_ product: Product) -> some View {
        Button {
            selectedProduct = product
        } label: {
            VStack(spacing: 6) {
                Image(uiImage: product.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 140)
                    .clipped()
                    .cornerRadius(12)
                    .shadow(radius: 4)
                
                Text(product.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(width: 140)
        }
        .buttonStyle(.plain)
    }
    
    
    
    
    func loadProductDataset() {
        guard let resourcePath = Bundle.main.resourcePath else {
            print("Resource path not found")
            return
        }
        
        let fm = FileManager.default
        do {
            let allFiles = try fm.subpathsOfDirectory(atPath: resourcePath)
            let imageFiles = allFiles.filter { $0.lowercased().hasSuffix(".jpg") || $0.lowercased().hasSuffix(".png") }
            
            for file in imageFiles {
                if let image = UIImage(named: file),
                   let feature = extractFeaturePrint(from: image) {
                    // extract folder name before "/"
                    let label = URL(fileURLWithPath: file)
                        .deletingPathExtension()
                        .lastPathComponent
                    let product = Product(name: label, image: image, feature: feature)
                    allProducts.append(product)
                }
            }
            print("Loaded \(allProducts.count) images from dataset")
        } catch {
            print("Error loading dataset:", error)
        }
    }
    
    
    func classifyAndCompare(_ image: UIImage) {
        selectedImage = image
        statusText = "Finding similar mounts..."
        
        guard let selectedFeature = extractFeaturePrint(from: image) else {
            statusText = "Could not extract features from input image."
            return
        }
        
        var matches: [(product: Product, distance: Float)] = []
        
        for product in allProducts {
            var distance: Float = 0
            do {
                try selectedFeature.computeDistance(&distance, to: product.feature)
                
                if distance < 0.6 {
                    matches.append((product, distance))
                    print("Match:", product.name, "distance:", distance)
                }
            } catch {
                print("Error computing distance:", error)
            }
        }
        
        similarProducts = matches.sorted(by: { $0.distance < $1.distance }).map { $0.product }
        
        if similarProducts.isEmpty {
            statusText = "No matching mounts found."
        } else {
            statusText = "Found \(similarProducts.count) similar mounts!"
        }
    }
    
    
    func extractFeaturePrint(from image: UIImage) -> VNFeaturePrintObservation? {
        guard let ciImage = CIImage(image: image) else { return nil }
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        let request = VNGenerateImageFeaturePrintRequest()
        do {
            try handler.perform([request])
            return request.results?.first as? VNFeaturePrintObservation
        } catch {
            print("Error generating feature print: \(error)")
            return nil
        }
    }
    
   
    
}


#Preview {
    ImageSearchView()
}
