//
//  LiveCameraTracking.swift
//  GestureApp
//
//  Created by Shraddha on 05/01/26.
//

import SwiftUI
import Vision
import AVFoundation

struct LiveCameraTextScanner: UIViewControllerRepresentable {
    let resetID: UUID
    var onTextDetected: (String) -> Void
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.reset()
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        
        let session = AVCaptureSession()
        session.sessionPreset = .high
        
        guard
            let device = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: device)
        else { return vc }
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(
            context.coordinator,
            queue: DispatchQueue(label: "camera.frame.processing")
        )
        
        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(output) { session.addOutput(output) }
        
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = vc.view.bounds
        
        vc.view.layer.addSublayer(preview)
        
        // START SESSION ON BACKGROUND THREAD
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
        
        return vc
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onTextDetected: onTextDetected)
    }
    
    final class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        private var lastScanTime = Date.distantPast
        private var didFreeze = false
        
        let onTextDetected: (String) -> Void
        
        func reset() {
            didFreeze = false
            lastScanTime = .distantPast
        }
        
        init(onTextDetected: @escaping (String) -> Void) {
            self.onTextDetected = onTextDetected
        }
        
        func captureOutput(
            _ output: AVCaptureOutput,
            didOutput sampleBuffer: CMSampleBuffer,
            from connection: AVCaptureConnection
        ) {
            guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            let request = VNRecognizeTextRequest { req, _ in
                guard let results = req.results as? [VNRecognizedTextObservation] else { return }
                
                let text = results
                    .compactMap { obs -> String? in
                        guard
                            let candidate = obs.topCandidates(1).first,
                            candidate.confidence > 0.7
                        else { return nil }
                        
                        return candidate.string
                    }
                    .joined(separator: "\n")
                
                guard text.count > 10 else { return }
                
                guard !self.didFreeze else { return }
                
                if TextValidator.isValidInspectionText(text) {
                    self.didFreeze = true
                    
                    DispatchQueue.main.async {
                        self.onTextDetected(text)
                    }
                }
                
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.minimumTextHeight = 0.05
            
            let handler = VNImageRequestHandler(cvPixelBuffer: buffer)
            try? handler.perform([request])
        }
    }
}
