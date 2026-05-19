//
//  MagicMirrorScreen.swift
//  PhotoProbe
//
//  Created by Shraddha on 09/01/26.
//

import SwiftUI

struct MagicMirrorScreenView: View {
    @State private var countdown: Int? = nil
    @State private var isCountingDown = false
    @EnvironmentObject var session: AppSession
    @State private var showGlassesPicker = false
    @State private var showHatPicker = false
    @State private var showHairPicker = false
    @State private var showPagadiPicker = false
    @State private var selectedHair: HairStyle = .japanese
    @State private var showCaptureAnimation = false
    @State private var capturedPreview: UIImage?
    @State private var showBeardPicker = false
   
    @State private var isUploading = false
    @State private var uploadedImageURL: String?
    @State private var showQR = false
    @State private var qrImage: UIImage?


    @State private var selectedGlasses: GlassesStyle = .astro
    @State private var selectedHat: HatStyle = .hat
    var isGlassesActive: Bool {
        activeFilters.contains { if case .glasses = $0 { return true } else { return false } }
    }
    
    var isHatActive: Bool {
        activeFilters.contains { if case .hat = $0 { return true } else { return false } }
    }
    
    
    @State private var activeFilters: Set<FaceFilter> = []
    
    var body: some View {
        ZStack {
            
            if isUploading {
                ZStack {
                    // Dark blurred background
                    Color.black
                        .opacity(0.55)
                        .ignoresSafeArea()
                        .transition(.opacity)

                    // Loader Card
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.4)

                        Text("Processing...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(30)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .shadow(radius: 10)
                }
                .zIndex(999)
                //.allowsHitTesting(true) // blocks touches behind
            }

            MagicMirrorView(
                filters: $activeFilters,
                onCapture: { image in
                    capturedPreview = image
                    
//                    withAnimation(.easeOut(duration: 0.25)) {
//                        showCaptureAnimation = true
//                    }
                    
                    uploadCapturedImage(image)
                    
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
//                        withAnimation {
//                            showCaptureAnimation = false
//                        }
//                    }
                }
                
            )
            .ignoresSafeArea()
            
            if let image = capturedPreview, showCaptureAnimation {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .modifier(CaptureFlyDown())
                    .zIndex(10)
            }
            
            if let countdown {
                CountdownOverlay(value: countdown)
                    .zIndex(20)
            }
            
            VStack {
                Spacer()
                
                HStack(spacing: 20) {
                    
                    Button {
                        showGlassesPicker = true
                    } label: {
                        Text("👓")
                            .font(.largeTitle)
                            .padding()
                            .background(isGlassesActive ? Color.blue.opacity(0.6) : .gray.opacity(0.4))
                            .clipShape(Circle())
                    }
                    
                    Button {
                        showHatPicker = true
                    } label: {
                        Text("🎩")
                            .font(.largeTitle)
                            .padding()
                            .background(isHatActive ? Color.blue.opacity(0.6) : .gray.opacity(0.4))
                            .clipShape(Circle())
                    }
                    
                    Button {
                        showHairPicker = true
                    } label: {
                        Text("👩‍🦱")
                            .font(.largeTitle)
                            .padding()
                            .background(
                                activeFilters.contains { if case .hair = $0 { return true } else { return false } }
                                ? Color.blue.opacity(0.6)
                                : Color.gray.opacity(0.4)
                            )
                            .clipShape(Circle())
                    }
                    
                    Button {
                        showBeardPicker = true
                    } label: {
                        Text("🧔")
                            .font(.largeTitle)
                            .padding()
                            .background(
                                activeFilters.contains { if case .beard = $0 { return true } else { return false } }
                                ? Color.blue.opacity(0.6)
                                : Color.gray.opacity(0.4)
                            )
                            .clipShape(Circle())
                    }
                    
                    Button {
                        showPagadiPicker = true
                    } label: {
                        Text("👳‍♂️")
                            .font(.largeTitle)
                            .padding()
                            .background(
                                activeFilters.contains { if case .pagadi = $0 { return true } else { return false } }
                                ? Color.blue.opacity(0.6)
                                : Color.gray.opacity(0.4)
                            )
                            .clipShape(Circle())
                    }
                    
                    
                    
                    // toggleButton("🖼️", .rejoiceFrame)
                    //toggleButton("🎖️", .rejoiceBadge)
                    //toggleButton("🧑‍🦰", .rejoiceHair)
                    // toggleButton("📅", .calendarFrame)
                    
                    
                    Button {
                        startCountdown()
                    } label: {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .padding(24)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    
                    
                    
                    
                }
                
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.bottom, 40)
            }
            
            
            //            .onReceive(NotificationCenter.default.publisher(for: .didPrepareCutout)) { note in
            //                guard let image = note.object as? UIImage else { return }
            //
            //                capturedPreview = image
            //
            //                withAnimation(.easeOut(duration: 0.2)) {
            //                    showCaptureAnimation = true
            //                }
            //
            //                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            //                    withAnimation(.easeInOut) {
            //                        showCaptureAnimation = false
            //                    }
            //                }
            //            }
            
            
            
            .onChange(of: session.showCalendarInMirror) { show in
                if show {
                    if let image = session.cutoutImage {
                        NotificationCenter.default.post(
                            name: .showCalendarOverlay,
                            object: image
                        )
                    } else {
                        print("❌ Calendar tapped but no cutout available")
                    }
                    
                    session.showCalendarInMirror = false
                }
            }
            
            .sheet(isPresented: $showGlassesPicker) {
                VStack {
//                    HStack {
////                        Text("Choose Glasses")
////                            .font(.headline)
////                            .padding(10)
//                        Spacer()
//                        Button {
//                            activeFilters = activeFilters.filter {
//                                if case .glasses = $0 { return false }
//                                return true
//                            }
//                            showGlassesPicker = false
//                        } label: {
//                            Label("Remove Filter", systemImage: "xmark.circle.fill")
//                                .fontWeight(.bold)
//                                .foregroundColor(.red)
//                        }
//                        Spacer()
//                    }
//                    .offset(y: -20)
                    
                    FilterSheetHeader(
                        title: "Choose Glass",
                        onRemove: {
                            activeFilters = activeFilters.filter {
                                if case .glasses = $0 { return false }
                                return true
                            }
                        },
                        onClose: {
                            showGlassesPicker = false
                        }
                    )
                    
                    Divider()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(GlassesStyle.allCases) { style in
                                Button {
                                    selectedGlasses = style
                                    
                                    // remove old
                                    activeFilters = activeFilters.filter {
                                        if case .glasses = $0 { return false }
                                        return true
                                    }
                                    
                                    // ✅ add new
                                    activeFilters.insert(.glasses(style))
                                    
                                   // showGlassesPicker = false
                                } label: {
                                    VStack {
                                        Image(style.imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 80, height: 40)
                                        
                                        Text(style.rawValue.capitalized)
                                    }
                                }
                            }
                        }
                    }
                }
                .presentationDetents([.height(180)])
            }
            
            
            .sheet(isPresented: $showHatPicker) {
                VStack {
                    FilterSheetHeader(
                        title: "Choose Hat",
                        onRemove: {
                            activeFilters = activeFilters.filter {
                                if case .hat = $0 { return false }
                                return true
                            }
                        },
                        onClose: {
                            showHatPicker = false
                        }
                    )
                    
                    Divider()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(HatStyle.allCases) { style in
                                Button {
                                    selectedHat = style
                                    
                                    
                                    activeFilters = activeFilters.filter {
                                        if case .hat = $0 { return false }
                                        return true
                                    }
                                    
                                    
                                    activeFilters.insert(.hat(style))
                                    
                                   // showHatPicker = false
                                } label: {
                                    VStack {
                                        Image(style.imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 80, height: 40)
                                        
                                        Text(style.rawValue.capitalized)
                                    }
                                }
                            }
                        }
                    }
                }
                .presentationDetents([.height(180)])
            }
            
            .sheet(isPresented: $showHairPicker) {
                VStack {
//                    Text("Choose Hair")
//                        .font(.headline)
//                        .padding()
//                    
//                    Button {
//                        activeFilters = activeFilters.filter {
//                            if case .hair = $0 { return false }
//                            return true
//                        }
//                        showHairPicker = false
//                    } label: {
//                        Label("Remove Filter", systemImage: "xmark.circle.fill")
//                            .foregroundColor(.red)
//                    }
                    
                    FilterSheetHeader(
                        title: "Choose Hair",
                        onRemove: {
                            activeFilters = activeFilters.filter {
                                if case .hair = $0 { return false }
                                return true
                            }
                        },
                        onClose: {
                            showHairPicker = false
                        }
                    )
                    
                    Divider()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(HairStyle.allCases) { style in
                                Button {
                                    selectedHair = style
                                    
                                    // remove old hair
                                    activeFilters = activeFilters.filter {
                                        if case .hair = $0 { return false }
                                        return true
                                    }
                                    
                                    // add new hair
                                    activeFilters.insert(.hair(style))
                                   // showHairPicker = false
                                    
                                } label: {
                                    VStack {
                                        Image(style.imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 80, height: 60)
                                        
                                        Text(style.rawValue.capitalized)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
                .presentationDetents([.height(180)])
            }
            
            .sheet(isPresented: $showBeardPicker) {
                VStack {
//                    Text("Choose Beard")
//                        .font(.headline)
//                        .padding()
//                    
//                    Button {
//                        activeFilters = activeFilters.filter {
//                            if case .beard = $0 { return false }
//                            return true
//                        }
//                        showBeardPicker = false
//                    } label: {
//                        Label("Remove Beard", systemImage: "xmark.circle.fill")
//                            .foregroundColor(.red)
//                    }
                    
                    FilterSheetHeader(
                        title: "Choose Beard",
                        onRemove: {
                            activeFilters = activeFilters.filter {
                                if case .beard = $0 { return false }
                                return true
                            }
                        },
                        onClose: {
                            showBeardPicker = false
                        }
                    )
                    
                    Divider()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(BeardStyle.allCases) { style in
                                Button {
                                    // Remove old beard
                                    activeFilters = activeFilters.filter {
                                        if case .beard = $0 { return false }
                                        return true
                                    }
                                    
                                    // Add new beard
                                    activeFilters.insert(.beard(style))
                                   // showBeardPicker = false
                                    
                                } label: {
                                    VStack {
                                        Image(style.imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 80, height: 50)
                                        
                                        Text(style.rawValue.capitalized)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
                .presentationDetents([.height(180)])
            }
            
            .sheet(isPresented: $showPagadiPicker) {
                VStack {
                    FilterSheetHeader(
                        title: "Choose Pagadi",
                        onRemove: {
                            activeFilters = activeFilters.filter {
                                if case .pagadi = $0 { return false }
                                return true
                            }
                        },
                        onClose: {
                            showPagadiPicker = false
                        }
                    )
                    
                    Divider()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(PagadiStyle.allCases) { style in
                                Button {
                                    // Remove old beard
                                    activeFilters = activeFilters.filter {
                                        if case .pagadi = $0 { return false }
                                        return true
                                    }
                                    
                                    // Add new beard
                                    activeFilters.insert(.pagadi(style))
                                   // showPagadiPicker = false
                                    
                                } label: {
                                    VStack {
                                        Image(style.imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 80, height: 50)
                                        
                                        Text(style.rawValue.capitalized)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
                .presentationDetents([.height(180)])
            }
//            .sheet(isPresented: $showQR) {
//                VStack(spacing: 20) {
//                    Text("Scan to Download")
//                        .font(.title2)
//                        .bold()
//
//                    if let qr = qrImage {
//                        Image(uiImage: qr)
//                            .resizable()
//                            .interpolation(.none)
//                            .scaledToFit()
//                            .frame(width: 250, height: 250)
//                            .background(Color.white)
//                            .cornerRadius(12)
//                    }
//
//                    Button("Close") {
//                        showQR = false
//                    }
//                }
//                .padding()
//            }
            if showQR {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Scan to Download")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)

                    if let qr = qrImage {
                        Image(uiImage: qr)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 250, height: 250)
                            .background(Color.white)
                            .cornerRadius(12)
                    }

                    Button("Close") {
                        withAnimation {
                            showQR = false
                        }
                        resetFiltersAndState()
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(10)
                }
                .transition(.scale)
                .zIndex(50)
            }

            
        }
        
    }
    
    private func resetFiltersAndState() {
        // Clear all filters
        activeFilters.removeAll()

        // Reset selections
        selectedGlasses = .astro
        selectedHat = .hat
        selectedHair = .japanese

        // Reset UI states
        showGlassesPicker = false
        showHatPicker = false
        showHairPicker = false
        showBeardPicker = false

        // Reset preview & QR
        qrImage = nil
        capturedPreview = nil
    }

    private func uploadCapturedImage(_ image: UIImage) {
        isUploading = true

        FileUploader.upload(image: image) { result in
            DispatchQueue.main.async {
                self.isUploading = false

                switch result {
                case .success(let imageURL):
                    print("Uploaded:", imageURL)

                    // Generate QR
                    self.qrImage = generateQRCode(from: imageURL)

                    // Show QR screen
                    self.showQR = true

                case .failure(let error):
                    print("Upload failed:", error.localizedDescription)
                }
            }
        }
    }
    
    private func toggleButton(_ emoji: String, _ filter: FaceFilter) -> some View {
        Button {
            if activeFilters.contains(filter) {
                activeFilters.remove(filter)
            } else {
                activeFilters.insert(filter)
            }
        } label: {
            Text(emoji)
                .font(.largeTitle)
                .padding()
                .background(activeFilters.contains(filter)
                            ? Color.blue.opacity(0.6)
                            : Color.gray.opacity(0.4))
                .clipShape(Circle())
        }
    }
    
    private func currentGlassesStyle(from filters: Set<FaceFilter>) -> GlassesStyle? {
        for filter in filters {
            if case let .glasses(style) = filter {
                return style
            }
        }
        return nil
    }
    
    
    private func startCountdown() {
        
        guard !isCountingDown else { return }
        
        isCountingDown = true
        countdown = 3
        
        for i in 1...3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                countdown = 3 - i
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            countdown = nil
            isCountingDown = false
            
            NotificationCenter.default.post(
                name: .captureMagicMirror,
                object: nil
            )
        }
    }
    
}


struct CountdownOverlay: View {
    
    let value: Int
    
    var body: some View {
        Text("\(value)")
            .font(.system(size: 120, weight: .bold))
            .foregroundColor(.white)
            .scaleEffect(1.2)
            .shadow(radius: 10)
            .transition(.scale.combined(with: .opacity))
    }
}

struct CaptureFlyDown: ViewModifier {
    @State private var scale: CGFloat = 1
    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 1
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .offset(y: offsetY)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8)) {
                    scale = 0.25
                    offsetY = 350
                    opacity = 0
                }
            }
    }
}

