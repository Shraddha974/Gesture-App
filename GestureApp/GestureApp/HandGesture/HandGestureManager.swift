//
//  HandGestureManager.swift
//  GestureApp
//
//  Created by Shraddha on 24/12/25.
//

import Vision
import AVFoundation
import SwiftUI
import Combine

final class HandGestureManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @Published var pinchPoint: CGPoint?
    @Published var didClick = false
    
    private let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let queue = DispatchQueue(label: "hand.gesture.queue")
    
    private let request = VNDetectHumanHandPoseRequest()
    
    override init() {
        super.init()
        setupCamera()
    }
}

extension HandGestureManager {
    
    private func setupCamera() {
        session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        session.addInput(input)
        
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        session.addOutput(videoOutput)
        
        session.startRunning()
    }
}

extension HandGestureManager {
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer,
                                            orientation: .leftMirrored)
        
        try? handler.perform([request])
        
        guard let hand = request.results?.first else { return }
        
        detectPinch(hand)
    }
}

private extension HandGestureManager {
    
    func detectPinch(_ hand: VNHumanHandPoseObservation) {
        
        guard
            let thumb = try? hand.recognizedPoint(.thumbTip),
            let index = try? hand.recognizedPoint(.indexTip),
            thumb.confidence > 0.6,
            index.confidence > 0.6
        else { return }
        
        let distance = hypot(thumb.location.x - index.location.x,
                             thumb.location.y - index.location.y)
        
        if distance < 0.05 {
            DispatchQueue.main.async {
                self.didClick = true
                self.pinchPoint = self.convertToScreen(index.location)
            }
        }
    }
    
    func convertToScreen(_ point: CGPoint) -> CGPoint {
        CGPoint(
            x: point.x * UIScreen.main.bounds.width,
            y: (1 - point.y) * UIScreen.main.bounds.height
        )
    }
}

