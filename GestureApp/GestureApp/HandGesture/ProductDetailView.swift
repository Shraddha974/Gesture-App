//
//  ProductDetailView.swift
//  GestureApp
//
//  Created by Shraddha on 05/01/26.
//

import SwiftUI


struct ProductDetailView: View {
    let product: Product
    @State private var showAR = false
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(product.name)
                    .font(.title)
                    .bold()
                    .padding(.top, 16)
                
                Image(uiImage: product.image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 220)
                    .cornerRadius(12)
                    .shadow(radius: 6)
                
                Button {
                    showAR = true
                } label: {
                    Label("View in AR", systemImage: "arkit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.trelleborgGold)
                        .cornerRadius(30)
                }
                //.buttonStyle(.borderedProminent)
                .padding(.horizontal)
                
                
                // Spacer()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("**Product Specifications**")
                        .font(.headline)
                    
                    specRow("Deflection", "5.4 mm")
                    specRow("Isolation", "77.9 %")
                    specRow("Natural Frequency", "7.0 Hz")
                    specRow("Max. Load", "50 kg")
                    specRow("Drawing no", "17-1600-1")
                    specRow("Part no", "10-00535")
                    specRow("Hardness", "45 IRHD")
                }
                .padding(.horizontal)
                
                Button(action: {
                    print("Send Results tapped for \(product.name)")
                }) {
                    Text("Send Results")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.trelleborgGold)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding(.bottom, 30)
        }
        .sheet(isPresented: $showAR) {
            ARPreviewView(
                productImage: product.image
            )
        }
        .navigationTitle("Specifications")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func specRow(_ key: String, _ value: String) -> some View {
        HStack {
            Text(key)
            Spacer()
            Text(value)
        }
    }
}
