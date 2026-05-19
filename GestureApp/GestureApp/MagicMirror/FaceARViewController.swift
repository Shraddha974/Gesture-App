//
//  FaceARViewController.swift
//  PhotoProbe
//
//  Created by Shraddha on 09/01/26.
//

import Foundation
import ARKit
import SceneKit
import SwiftUI
import Photos
import Vision

enum FaceFilter: Hashable {
    case glasses(GlassesStyle)
    case hat(HatStyle)
    case hair(HairStyle)
    case beard(BeardStyle)
    case pagadi(PagadiStyle)
    case rejoiceFrame
    case rejoiceBadge
    case rejoiceHair
    case calendarFrame
    case hairFrame
    
}

final class FaceARViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    private let sceneView = ARSCNView()
    
    private let glassesNode = SCNNode()
    private let hatNode = SCNNode()
    private let rejoiceFrameNode = SCNNode()
    private let rejoiceBadgeNode = SCNNode()
    private let bottomRibbonNode = SCNNode()
    private let calendarNode = SCNNode()
    private let personNode = SCNNode()
    private let hairNode = SCNNode()
    private let beardNode = SCNNode()
    private let pagadiNode = SCNNode()
    var onImageCaptured: ((UIImage) -> Void)?
    
    private let ribbonFinalPosition = SCNVector3(0, -0.18, -0.45)
    
    private let ribbonStartOffset: Float = 0.25
    
    var activeFilters: Set<FaceFilter> = []
    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    private var lastCaptureTime: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCapture),
            name: .captureMagicMirror,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showCalendar(_:)),
            name: .showCalendarOverlay,
            object: nil
        )
        
        
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        sceneView.frame = view.bounds
        view.addSubview(sceneView)
        
        sceneView.scene = SCNScene()
        sceneView.automaticallyUpdatesLighting = true
        
        
        setupNodes()
    }
    
    @objc private func showCalendar(_ note: Notification) {
        
        print("📅 showCalendar notification received")
        
        guard let image = note.object as? UIImage else {
            print("❌ No cutout image received")
            return
        }
        
        print("✅ Cutout image received")
        
        DispatchQueue.main.async {
            self.showCalendarInternal(with: image)
        }
    }
    
    private func showCalendarInternal(with image: UIImage) {
        
        // REMOVE previous if exists
        calendarNode.removeFromParentNode()
        personNode.removeFromParentNode()
        
        setupCalendarNode()
        setupPersonNode(with: image)
        
        sceneView.scene.rootNode.addChildNode(calendarNode)
        calendarNode.addChildNode(personNode)
        
        calendarNode.isHidden = false
        
        print("Calendar node added to scene")
    }
    
    
    @objc private func handleCapture() {
        
        captureAndSaveToGallery()
    }
    
    //    private func handleGestureCapture() {
    //
    //        let now = CACurrentMediaTime()
    //        guard now - lastCaptureTime > 5 else { return }
    //
    //        lastCaptureTime = now
    //
    //        print("✋ Gesture detected → waiting 5 seconds")
    //
    //        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    //            self.captureAndSaveToGallery()
    //            // self.provideHapticFeedback()
    //            print("Captured after 5 sec delay")
    //        }
    //    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let config = ARFaceTrackingConfiguration()
        sceneView.session.run(config)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        attachRibbonToCamera()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        attachRibbonToCamera()
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    //    private func isOpenPalm(_ observation: VNHumanHandPoseObservation) -> Bool {
    //
    //        guard
    //            let thumb = try? observation.recognizedPoint(.thumbTip),
    //            let index = try? observation.recognizedPoint(.indexTip),
    //            let middle = try? observation.recognizedPoint(.middleTip),
    //            let ring = try? observation.recognizedPoint(.ringTip),
    //            let little = try? observation.recognizedPoint(.littleTip)
    //        else { return false }
    //
    //        let points = [thumb, index, middle, ring, little]
    //        return points.allSatisfy { $0.confidence > 0.5 }
    //    }
    
    //    func session(_ session: ARSession,didUpdate frame: ARFrame) {
    //
    //        let pixelBuffer = frame.capturedImage
    //
    //        let handler = VNImageRequestHandler(
    //            cvPixelBuffer: pixelBuffer,
    //            orientation: .leftMirrored
    //        )
    //
    //        do {
    //            try handler.perform([handPoseRequest])
    //        } catch {
    //            print("Vision error:", error)
    //            return
    //        }
    //
    //        if let hand = handPoseRequest.results?.first {
    //            if isOpenPalm(hand) {
    //                handleGestureCapture()
    //            }
    //        }
    //    }
    
    
}

private extension FaceARViewController {
    
    private func setupNodes() {
        
        setupGlass()
        animateGlasses()
        
        setupHat()
       // animateHat()
        
        setupHair()
        setupPagadi()
        // Instagram Rejoice Frame
        setupRejoiceFrame()
        setupRejoiceBadge()
        setupBottomRibbon()
        setupCalendarFrame()
        
        
    }
    
    
    
    func setupGlass() {
        // Glasses
        let glasses = SCNPlane(width: 0.14, height: 0.05)
        glasses.firstMaterial?.diffuse.contents = UIImage(named: "glasses")
        glasses.firstMaterial?.isDoubleSided = true
        glassesNode.geometry = glasses
        glassesNode.position = SCNVector3(0, 0.02, 0.06)
        glassesNode.isHidden = true
    }
//    
//    private func setupPagadi() {
//        guard let image = UIImage(named: "marathi") else { return }
//
//        let aspect = image.size.height / image.size.width
//        let width: CGFloat = 0.22
//        let height = width * aspect
//
//        let hat = SCNPlane(width: width, height: height)
//        hat.firstMaterial?.diffuse.contents = image
//        hat.firstMaterial?.isDoubleSided = true
//        hat.firstMaterial?.writesToDepthBuffer = false
//
//        pagadiNode.geometry = hat
//
//        // 👑 SETTLED ON TOP OF HEAD
//        pagadiNode.position = SCNVector3(
//            0,
//            0.12 + Float(height / 2),
//            0.02
//        )
//
//        pagadiNode.eulerAngles.x = -.pi / 14
//        pagadiNode.renderingOrder = 15
//        pagadiNode.isHidden = true
//    }
    
    private func setupPagadi() {
        guard let image = UIImage(named: "marathi") else { return }

        let aspect = image.size.height / image.size.width

        // Pagadi should be wider than tall
        let width: CGFloat = 0.30
        let height = width * aspect

        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial?.diffuse.contents = image
        plane.firstMaterial?.isDoubleSided = true
        plane.firstMaterial?.writesToDepthBuffer = false

        pagadiNode.geometry = plane

        // KEY FIX: move UP by half height + offset
        pagadiNode.position = SCNVector3(
            0.0,
            Float(height / 2) + 0.02, // ⬅️ THIS is the real fix
            0.02
        )

        // Gentle forward tilt (emoji-like)
        pagadiNode.eulerAngles.x = -.pi / 14

        pagadiNode.renderingOrder = 15
        pagadiNode.isHidden = true
    }





    func setupHat() {
        
        guard let image = UIImage(named: "hat") else { return }
        
        let aspect = image.size.height / image.size.width
        let width: CGFloat = 0.22
        let height = width * aspect
        
        let hat = SCNPlane(width: width, height: height)
        hat.firstMaterial?.diffuse.contents = image
        hat.firstMaterial?.isDoubleSided = true
        
        hatNode.geometry = hat
        
        // Move slightly upward
        hatNode.position = SCNVector3(0, 0.19, 0)
        
        
        // Natural tilt
        hatNode.eulerAngles.x = -.pi / 10
        
        hatNode.renderingOrder = 10
        hatNode.isHidden = true
    }
    
    func setupHair() {
        
        //        guard let image = UIImage(named: "hair") else { return }
        //
        //        let aspect = image.size.height / image.size.width
        //
        //        // 👇 Hair should be wider than hat
        //        let width: CGFloat = 0.28
        //        let height = width * aspect
        //
        //        let hairPlane = SCNPlane(width: width, height: height)
        //        hairPlane.firstMaterial?.diffuse.contents = image
        //        hairPlane.firstMaterial?.isDoubleSided = true
        //        hairPlane.firstMaterial?.lightingModel = .physicallyBased
        //
        //        let hairNode = SCNNode(geometry: hairPlane)
        //
        //        // Correct position for hair
        //        hairNode.position = SCNVector3(
        //            0,      // center
        //            0.22,   // UP (important)
        //            0.02    // slightly forward
        //        )
        //
        //        // Natural tilt
        //        hairNode.eulerAngles.x = -.pi / 10
        //
        //        hairNode.renderingOrder = 20
        //        hairNode.name = "hair"
        
        //  self.hairNode = hairNode
    }
    
    private func setupCalendarFrame() {
        
        let plane = SCNPlane(
            width: 0.42,
            height: 0.32
        )
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "calendar_booth")
        material.isDoubleSided = true
        material.lightingModel = .constant
        material.writesToDepthBuffer = false
        material.readsFromDepthBuffer = false
        
        plane.materials = [material]
        calendarNode.geometry = plane
        
        // 👇 SAME IDEA AS INSTAGRAM FRAME
        calendarNode.position = SCNVector3(0, -0.02, 0.23)
        calendarNode.isHidden = true
    }
    
    private func setupCalendarNode() {
        
        let plane = SCNPlane(width: 0.45, height: 0.32)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "calendar_booth")
        material.lightingModel = .constant
        material.isDoubleSided = true
        material.writesToDepthBuffer = false
        material.readsFromDepthBuffer = false
        
        plane.materials = [material]
        calendarNode.geometry = plane
        
        // 🔥 FORCE FRONT OF CAMERA
        calendarNode.position = SCNVector3(0, 0, -0.6)
        
        calendarNode.eulerAngles = SCNVector3Zero
        calendarNode.isHidden = true
    }
    
    
    private func setupPersonNode(with image: UIImage) {
        
        let plane = SCNPlane(width: 0.2, height: 0.28)
        
        let material = SCNMaterial()
        material.diffuse.contents = image
        material.lightingModel = .constant
        material.isDoubleSided = true
        material.writesToDepthBuffer = false
        material.readsFromDepthBuffer = false
        
        plane.materials = [material]
        personNode.geometry = plane
        
        // 🔥 Slightly in front of calendar
        personNode.position = SCNVector3(0, -0.02, 0.01)
    }
    
    
    
    private func setupRejoiceFrame() {
        
        let framePlane = SCNPlane(
            width: 0.32,
            height: 0.42
        )
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "rejoice_instagram_frame")
        material.isDoubleSided = true
        material.writesToDepthBuffer = false
        material.readsFromDepthBuffer = false
        
        framePlane.materials = [material]
        
        rejoiceFrameNode.geometry = framePlane
        rejoiceFrameNode.position = SCNVector3(0, -0.06, 0.22)
        
        rejoiceFrameNode.isHidden = true
    }
    
    private func setupBottomRibbon() {
        
        
        
        // BIG CHANGE HERE (thicker ribbon)
        let ribbonWidth: CGFloat = 0.58
        let ribbonHeight: CGFloat = ribbonWidth / 2.6
        
        
        let plane = SCNPlane(
            width: ribbonWidth,
            height: ribbonHeight
        )
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "rejoice_ribbon")
        material.isDoubleSided = true
        material.lightingModel = .constant
        material.writesToDepthBuffer = false
        material.readsFromDepthBuffer = false
        
        plane.materials = [material]
        
        bottomRibbonNode.geometry = plane
        bottomRibbonNode.isHidden = true
    }
    
    
    private func setupRejoiceBadge() {
        
        let badgePlane = SCNPlane(width: 0.08, height: 0.08)
        
        let material = SCNMaterial()
        material.diffuse.contents = createBadgeImage()
        material.isDoubleSided = true
        material.writesToDepthBuffer = false
        material.readsFromDepthBuffer = false
        
        badgePlane.materials = [material]
        
        rejoiceBadgeNode.geometry = badgePlane
        
        // 📍 Position near shoulder
        rejoiceBadgeNode.position = SCNVector3(0.09, -0.03, 0.08)
        
        rejoiceBadgeNode.isHidden = true
        
        animateRejoiceBadge()
    }
    
    private func createBadgeImage() -> UIImage {
        
        let size = CGSize(width: 256, height: 256)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { ctx in
            
            // Background circle
            UIColor.systemYellow.setFill()
            ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
            
            // Border
            ctx.cgContext.setStrokeColor(UIColor.white.cgColor)
            ctx.cgContext.setLineWidth(12)
            ctx.cgContext.strokeEllipse(in: CGRect(x: 6, y: 6, width: 244, height: 244))
            
            // Text
            let text = "🎉\nRejoice\n2025"
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 36),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraph
            ]
            
            let rect = CGRect(x: 0, y: 70, width: size.width, height: 120)
            text.draw(in: rect, withAttributes: attrs)
        }
    }
    
    private func playRibbonSlideIn() {
        
        guard bottomRibbonNode.parent != nil else {
            // Camera not ready yet — retry next frame
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.playRibbonSlideIn()
            }
            return
        }
        
        bottomRibbonNode.removeAllActions()
        
        // FORCE RESET POSITION (below screen)
        bottomRibbonNode.position = SCNVector3(
            ribbonFinalPosition.x,
            ribbonFinalPosition.y - ribbonStartOffset,
            ribbonFinalPosition.z
        )
        
        bottomRibbonNode.opacity = 0
        bottomRibbonNode.isHidden = false
        
        let moveUp = SCNAction.move(to: ribbonFinalPosition, duration: 0.4)
        moveUp.timingMode = .easeOut
        
        let fadeIn = SCNAction.fadeIn(duration: 0.25)
        
        bottomRibbonNode.runAction(.group([moveUp, fadeIn]))
    }
    
    
    private func animateRejoiceBadge() {
        
        let up = SCNAction.moveBy(x: 0, y: 0.004, z: 0, duration: 1)
        let down = SCNAction.moveBy(x: 0, y: -0.004, z: 0, duration: 1)
        
        let float = SCNAction.sequence([up, down])
        rejoiceBadgeNode.runAction(.repeatForever(float))
    }
    
}


extension FaceARViewController {
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard anchor is ARFaceAnchor else { return nil }
        
        let faceNode = SCNNode()
        faceNode.addChildNode(glassesNode)
        faceNode.addChildNode(hatNode)
        faceNode.addChildNode(rejoiceFrameNode)
        faceNode.addChildNode(rejoiceBadgeNode)
        faceNode.addChildNode(calendarNode)
        faceNode.addChildNode(hairNode)
        faceNode.addChildNode(beardNode)
        faceNode.addChildNode(pagadiNode)
        return faceNode
    }
    
    //    func renderer(_ renderer: SCNSceneRenderer,
    //                  didUpdate node: SCNNode,
    //                  for anchor: ARAnchor) {
    //
    //        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
    //
    //        updateBeardPosition(faceAnchor)
    //    }
    //
    func updateBeardPosition(_ faceAnchor: ARFaceAnchor) {
        
        let transform = faceAnchor.transform
        
        // --- Extract head pitch (X rotation) ---
        let pitch = atan2(
            transform.columns.2.y,
            transform.columns.2.z
        )
        
        // --- Mouth movement ---
        let jawOpen = faceAnchor.blendShapes[.jawOpen]?.floatValue ?? 0
        
        // --- Position tuning ---
        var yOffset: Float = -0.045
        var zOffset: Float = 0.03
        
        // Dynamic correction
        yOffset -= jawOpen * 0.03         // move down when mouth opens
        zOffset += abs(pitch) * 0.02      // move forward when head tilts
        
        let beardOffset = simd_float4x4(
            SIMD4(1, 0, 0, 0),
            SIMD4(0, 1, 0, yOffset),
            SIMD4(0, 0, 1, zOffset),
            SIMD4(0, 0, 0, 1)
        )
        
        // Apply transform
        beardNode.simdTransform = simd_mul(transform, beardOffset)
        
        // Natural tilt toward neck
        beardNode.eulerAngles.x = -.pi / 2.3
    }
    
    
    
    //    func updateBeardPosition(_ faceAnchor: ARFaceAnchor) {
    //
    //        // Beard relative to face center
    //        let beardX: Float = 0
    //        let beardY: Float = -0.07
    //        let beardZ: Float = 0.025
    //
    //        beardNode.position = SCNVector3(
    //            beardX,
    //            beardY,
    //            beardZ
    //        )
    //
    //        // Tilt beard naturally toward neck
    //        beardNode.eulerAngles.x = -.pi / 2.4
    //    }
    
    
    private func attachRibbonToCamera() {
        guard let cameraNode = sceneView.pointOfView,
              bottomRibbonNode.parent == nil else { return }
        
        cameraNode.addChildNode(bottomRibbonNode)
    }
    
    
    //    func updateFilters(_ filters: Set<FaceFilter>) {
    //
    //        activeFilters = filters
    //
    //        glassesNode.isHidden = !filters.contains {
    //               if case .glasses = $0 { return true }
    //               return false
    //           }
    //
    //           hatNode.isHidden = !filters.contains {
    //               if case .hat = $0 { return true }
    //               return false
    //           }
    //        rejoiceFrameNode.isHidden = !filters.contains(.rejoiceFrame)
    //        rejoiceBadgeNode.isHidden = !filters.contains(.rejoiceBadge)
    //        calendarNode.isHidden = !filters.contains(.calendarFrame)
    //
    //
    //        if filters.contains(.rejoiceRibbon) {
    //                playRibbonSlideIn()
    //            } else {
    //                bottomRibbonNode.removeAllActions()
    //                bottomRibbonNode.isHidden = true
    //            }
    //
    //    }
    
    func updateFilters(_ filters: Set<FaceFilter>) {
        
        activeFilters = filters
        
        // -------------------------
        // GLASSES
        // -------------------------
        if let glassesStyle = filters.compactMap({
            if case let .glasses(style) = $0 { return style }
            return nil
        }).first {
            
            glassesNode.isHidden = false
            applyGlasses(style: glassesStyle)
            
        } else {
            glassesNode.isHidden = true
        }
        
        // -------------------------
        // HAT
        // -------------------------
        if let hatStyle = filters.compactMap({
            if case let .hat(style) = $0 { return style }
            return nil
        }).first {
            
            hatNode.isHidden = false
            applyHat(style: hatStyle)
            
        } else {
            hatNode.isHidden = true
        }
        
        if let hairStyle = filters.compactMap({
            if case let .hair(style) = $0 { return style }
            return nil
        }).first {
            
            hairNode.isHidden = false
            applyHair(hairStyle)
            
        } else {
            hairNode.isHidden = true
        }
        
        if let beardStyle = filters.compactMap({
            if case let .beard(style) = $0 { return style }
            return nil
        }).first {
            
            beardNode.isHidden = false
            applyBeard(beardStyle)
            
        } else {
            beardNode.isHidden = true
        }
        
        if let pagadiStyle = filters.compactMap({
            if case let .pagadi(style) = $0 { return style }
            return nil
        }).first {
            
            pagadiNode.isHidden = false
            applyPagadiHat(style: pagadiStyle)
            
        } else {
            pagadiNode.isHidden = true
        }
        
        // -------------------------
        // OTHER FILTERS
        // -------------------------
        rejoiceFrameNode.isHidden = !filters.contains(.rejoiceFrame)
        rejoiceBadgeNode.isHidden = !filters.contains(.rejoiceBadge)
        calendarNode.isHidden = !filters.contains(.calendarFrame)
        //hairNode.isHidden = !filters.contains(.hairFrame)
        
        if filters.contains(.rejoiceHair) {
            playRibbonSlideIn()
        } else {
            bottomRibbonNode.removeAllActions()
            bottomRibbonNode.isHidden = true
        }
    }
    
    private func applyGlasses(style: GlassesStyle) {
        let image = UIImage(named: style.imageName)
        
        glassesNode.geometry?.firstMaterial?.diffuse.contents = image
        glassesNode.geometry?.firstMaterial?.isDoubleSided = true
    }
    
//    private func applyHat(style: HatStyle) {
//        let image = UIImage(named: style.rawValue)
//        hatNode.geometry?.firstMaterial?.diffuse.contents = image
//    }
    
    private func applyHat(style: HatStyle) {

        guard let image = UIImage(named: style.rawValue) else { return }
        let aspect = image.size.height / image.size.width
        let width: CGFloat
            let yPosition: Float
            let zPosition: Float
            let tilt: Float
        //resetHatNode()

        switch style {

            case .jack:
                width = 0.30                    // wider
                yPosition = 0.02                // top of head
                zPosition = 0.02
                tilt = 0                        // straight

            default:
                width = 0.22                    // normal hat
                yPosition = 0.06              // default position
                zPosition = 0.0
                tilt = -.pi / 10
            }
        let height = width * aspect

           let plane = SCNPlane(width: width, height: height)
           plane.firstMaterial?.diffuse.contents = image
           plane.firstMaterial?.isDoubleSided = true
           plane.firstMaterial?.writesToDepthBuffer = false

           hatNode.geometry = plane

           // Position using fresh geometry
           hatNode.position = SCNVector3(
               0,
               yPosition + Float(height / 2),
               zPosition
           )

           // ✅ Rotation
           hatNode.eulerAngles = SCNVector3(tilt, 0, 0)

           // ✅ Reset other state
           hatNode.scale = SCNVector3(1, 1, 1)
           hatNode.renderingOrder = 10
           hatNode.isHidden = false
        
    }
    
    private func resetHatNode() {
        hatNode.removeAllActions()
        hatNode.scale = SCNVector3(1, 1, 1)
        hatNode.eulerAngles = SCNVector3Zero
        hatNode.position = SCNVector3(0, 0.19, 0)
        hatNode.renderingOrder = 10
    }

    func applyHair(_ style: HairStyle) {
        
        guard let image = UIImage(named: style.imageName) else { return }
        
        let aspect = image.size.height / image.size.width
        let width: CGFloat = 0.34
        let height = width * aspect
        
        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial?.diffuse.contents = image
        plane.firstMaterial?.isDoubleSided = true
        plane.firstMaterial?.writesToDepthBuffer = false
        
        hairNode.geometry = plane
        
        // 🔥 LOWER PLACEMENT (Natural Hairline)
        hairNode.position = SCNVector3(
            0.0,
            0.06,   // ↓ moved down
            0.04
        )
        
        hairNode.eulerAngles = SCNVector3(0, 0, 0)
        hairNode.renderingOrder = 20
        hairNode.isHidden = false
    }
    
    func applyBeard(_ style: BeardStyle) {
        
        let beardPlane = SCNPlane(
            width: 0.14,
            height: 0.18
        )
        
        beardPlane.firstMaterial?.diffuse.contents =
        UIImage(named: style.imageName)
        
        beardPlane.firstMaterial?.isDoubleSided = true
        beardPlane.firstMaterial?.lightingModel = .physicallyBased
        
        beardNode.geometry = beardPlane
        
        // MOVE BEARD DOWN (THIS IS THE FIX)
        beardNode.position = SCNVector3(
            0,        // center
            -0.09,    //
            0.025     // slightly forward
        )
        
        // NATURAL TILT
        //  beardNode.eulerAngles.x = -.pi / 2.3
        
        beardNode.isHidden = false
    }
    
    private func applyPagadiHat(style: PagadiStyle) {
        guard let image = UIImage(named: style.rawValue) else { return }

       
        let aspect = image.size.height / image.size.width

        // Pagadi should be wider than tall
        let width: CGFloat = 0.30
        let height = width * aspect

        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial?.diffuse.contents = image
        plane.firstMaterial?.isDoubleSided = true
        plane.firstMaterial?.writesToDepthBuffer = false

        pagadiNode.geometry = plane

        // KEY FIX: move UP by half height + offset
        pagadiNode.position = SCNVector3(
            0.0,
            Float(height / 2) + 0.02, // ⬅️ THIS is the real fix
            0.02
        )

        // Gentle forward tilt (emoji-like)
        pagadiNode.eulerAngles.x = -.pi / 14

        pagadiNode.renderingOrder = 15
       // pagadiNode.isHidden = true
    
    }

    
    
    //    func applyBeard(_ style: BeardStyle) {
    //
    //        let beardPlane = SCNPlane(
    //            width: 0.14,
    //            height: 0.18
    //        )
    //
    //        beardPlane.firstMaterial?.diffuse.contents =
    //            UIImage(named: style.imageName)
    //
    //        beardPlane.firstMaterial?.isDoubleSided = true
    //        beardPlane.firstMaterial?.lightingModel = .physicallyBased
    //
    //        beardNode.geometry = beardPlane
    //        beardNode.isHidden = false
    //
    //
    //    }
    
    
    
    
    private func animateHat() {
        
        let up = SCNAction.moveBy(x: 0, y: 0.01, z: 0, duration: 1)
        let down = SCNAction.moveBy(x: 0, y: -0.01, z: 0, duration: 1)
        
        let float = SCNAction.sequence([up, down])
        hatNode.runAction(.repeatForever(float))
    }
    
    private func animateGlasses() {
        
        let scaleUp = SCNAction.scale(to: 1.05, duration: 0.6)
        let scaleDown = SCNAction.scale(to: 1.0, duration: 0.6)
        
        let pulse = SCNAction.sequence([scaleUp, scaleDown])
        glassesNode.runAction(.repeatForever(pulse))
    }
    
    
    
    func captureAndSaveToGallery() {
        
        let image = sceneView.snapshot()
        
        guard image.size.width > 0 else {
            print("Snapshot failed")
            return
        }
        
        DispatchQueue.main.async {
            self.onImageCaptured?(image)
        }
    }
    
    //        PHPhotoLibrary.requestAuthorization { status in
    //            guard status == .authorized || status == .limited else {
    //                print("Photo permission denied")
    //                return
    //            }
    //
    //            PHPhotoLibrary.shared().performChanges({
    //                PHAssetChangeRequest.creationRequestForAsset(from: image)
    //            }) { success, error in
    //                if success {
    //                    print("Saved to gallery")
    //                } else {
    //                    print("Save failed:", error ?? "")
    //                }
    //            }
    //        }
    
    
    
    
    func captureAndProcessPhoto() {
        
        let image = sceneView.snapshot()
        
        BackgroundRemover.removeBackground(from: image) { cutout in
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .didPrepareCutout,
                    object: cutout
                )
            }
        }
    }
    
    
}




extension Notification.Name {
    static let captureMagicMirror = Notification.Name("captureMagicMirror")
    static let startCountdown = Notification.Name("startCountdown")
    static let didPrepareCutout = Notification.Name("didPrepareCutout")
    static let showCalendarOverlay =
    Notification.Name("showCalendarOverlay")
}
