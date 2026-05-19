//
//  ARPreviewView.swift
//  GestureApp
//
//  Created by Shraddha on 05/01/26.
//

import SwiftUI
import RealityKit
import ARKit
import AVFoundation
import Vision

struct ARPreviewView: UIViewRepresentable {

    let productImage: UIImage

    func makeUIView(context: Context) -> ARContainerView {
        let view = ARContainerView(productImage: productImage)
        return view
    }

    func updateUIView(_ uiView: ARContainerView, context: Context) {}
}

// MARK: - AR Container View
final class ARContainerView: UIView {

    private let arView = ARView(frame: .zero)
    private let productImage: UIImage

    // RealityKit
    private var modelEntity: ModelEntity?
    private var modelPlaced = false

    // Camera + Vision
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let captureQueue = DispatchQueue(label: "FrontCameraQueue", qos: .userInteractive)
    private let handRequest = VNDetectHumanHandPoseRequest()

    // Throttle vision
    private var lastVisionTime: CFTimeInterval = 0
    private let visionFPS: CFTimeInterval = 1.0 / 20.0

    // Gesture baselines
    private var baselinePinch: CGFloat?
    private var baselineScale: Float = 1.0
    private var currentScale: Float = 1.0

    private var baselineAngle: CGFloat?
    private var baselineYaw: Float = 0.0
    private var currentYaw: Float = 0.0

    // Smoothing factors
    private let scaleSmooth: Float = 0.18
    private let rotationSmooth: Float = 0.16

    // Limits
    private let minScale: Float = 0.3
    private let maxScale: Float = 3.0

    init(productImage: UIImage) {
        self.productImage = productImage
        super.init(frame: .zero)

        setupAR()
        placeModel()
        setupFrontCamera()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        arView.frame = bounds
    }

    // MARK: - AR Setup
    private func setupAR() {
        addSubview(arView)
        arView.automaticallyConfigureSession = false

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = []
        arView.session.run(config)
    }

    // MARK: - Place 3D Object
    private func placeModel() {
        guard let cg = productImage.cgImage else { return }

        guard let texture = try? TextureResource.generate(
            from: cg,
            options: .init(semantic: .color)
        ) else { return }

        var material = UnlitMaterial()
        material.baseColor = .texture(texture)

        let mesh = MeshResource.generatePlane(width: 0.4, height: 0.4)
        let model = ModelEntity(mesh: mesh, materials: [material])


        var mat = UnlitMaterial()
        mat.baseColor = .texture(texture)

//        let mesh = MeshResource.generatePlane(width: 0.4, height: 0.4)
//        let model = ModelEntity(mesh: mesh, materials: [mat])
        self.modelEntity = model

        model.scale = SIMD3<Float>(repeating: 1.0)

        var transform = matrix_identity_float4x4
        transform.columns.3.z = -0.5  // closer so zoom feels bigger

        let anchor = AnchorEntity(world: transform)
        anchor.addChild(model)
        arView.scene.addAnchor(anchor)

        modelPlaced = true
    }

    // MARK: - FRONT CAMERA + VISION
    private func setupFrontCamera() {

        handRequest.maximumHandCount = 1

        captureQueue.async { [weak self] in
            guard let self = self else { return }

            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .medium

            guard let cam = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                    for: .video,
                                                    position: .front),
                  let input = try? AVCaptureDeviceInput(device: cam)
            else { return }

            if self.captureSession.canAddInput(input) {
                self.captureSession.addInput(input)
            }

            self.videoOutput.setSampleBufferDelegate(self, queue: self.captureQueue)
            self.videoOutput.alwaysDiscardsLateVideoFrames = true
            self.videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String:
                    kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
            ]

            if self.captureSession.canAddOutput(self.videoOutput) {
                self.captureSession.addOutput(self.videoOutput)
                if let conn = self.videoOutput.connection(with: .video) {
                    conn.videoOrientation = .portrait
                    conn.isVideoMirrored = true
                }
            }

            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
    }
}

// MARK: - Vision Processing
extension ARContainerView: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        let now = CACurrentMediaTime()
        if now - lastVisionTime < visionFPS { return }
        lastVisionTime = now

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .leftMirrored,
            options: [:]
        )

        do {
            try handler.perform([handRequest])

            guard let result = handRequest.results?.first else {
                baselinePinch = nil
                baselineAngle = nil
                return
            }

            processHand(result)

        } catch {
            print("Vision Error:", error)
        }
    }

    private func processHand(_ obs: VNHumanHandPoseObservation) {

        guard
            let thumb = try? obs.recognizedPoint(.thumbTip),
            let index = try? obs.recognizedPoint(.indexTip),
            thumb.confidence > 0.3,
            index.confidence > 0.3
        else {
            baselinePinch = nil
            baselineAngle = nil
            return
        }

        let t = CGPoint(x: thumb.location.x, y: thumb.location.y)
        let i = CGPoint(x: index.location.x, y: index.location.y)

        let dx = t.x - i.x
        let dy = t.y - i.y

        // Pinch Distance
        let pinch = sqrt(dx*dx + dy*dy)

        // Rotation Angle
        let angle = atan2(dy, dx)

        // MARK: - BASELINES
        if baselinePinch == nil {
            baselinePinch = pinch
            baselineScale = currentScale
        }

        if baselineAngle == nil {
            baselineAngle = angle
            baselineYaw = currentYaw
        }

        guard let basePinch = baselinePinch else { return }

        // MARK: - PINCH -> SCALE
        let ratio = pinch / basePinch
        let proposedScale = baselineScale * Float(ratio)

        DispatchQueue.main.async {
            self.applyScale(proposedScale)
        }

        // MARK: - ROTATION -> YAW
        if let baseA = baselineAngle {
            let delta = angle - baseA
            let yaw = baselineYaw - Float(delta)
            DispatchQueue.main.async {
                self.applyRotation(yaw)
            }
        }
    }
}

// MARK: - Apply SCALE & ROTATION (RealityKit)
extension ARContainerView {

    private func applyScale(_ scale: Float) {
        guard let model = modelEntity else { return }

        let clamped = max(minScale, min(maxScale, scale))
        currentScale = lerp(currentScale, clamped, scaleSmooth)

        model.scale = SIMD3<Float>(repeating: currentScale)
    }

    private func applyRotation(_ yaw: Float) {
        guard let model = modelEntity else { return }

        currentYaw = lerp(currentYaw, yaw, rotationSmooth)

        var transform = model.transform
        transform.rotation = simd_quatf(angle: currentYaw, axis: SIMD3<Float>(0,1,0))
        model.transform = transform
    }

    private func lerp(_ a: Float, _ b: Float, _ t: Float) -> Float {
        return a + (b - a) * t
    }
}
