//
//  BackgroundRemover.swift
//  GestureApp
//
//  Created by Shraddha on 13/01/26.
//

import UIKit
import Vision
import CoreImage

final class BackgroundRemover {

    static func removeBackground(
        from image: UIImage,
        completion: @escaping (UIImage?) -> Void
    ) {

        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }

        let request = VNGeneratePersonSegmentationRequest()
        request.qualityLevel = .accurate
        request.outputPixelFormat = kCVPixelFormatType_OneComponent8

        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])

                guard
                    let maskBuffer = request.results?.first?.pixelBuffer
                else {
                    completion(nil)
                    return
                }

                let originalCI = CIImage(cgImage: cgImage)
                let maskCI = CIImage(cvPixelBuffer: maskBuffer)

                let resizedMask = maskCI
                    .transformed(by: CGAffineTransform(
                        scaleX: originalCI.extent.width / maskCI.extent.width,
                        y: originalCI.extent.height / maskCI.extent.height
                    ))

                let outputCI = originalCI.applyingFilter(
                    "CIBlendWithMask",
                    parameters: [
                        kCIInputMaskImageKey: resizedMask
                    ]
                )

                let context = CIContext()
                if let outputCG = context.createCGImage(outputCI, from: outputCI.extent) {
                    completion(UIImage(cgImage: outputCG))
                } else {
                    completion(nil)
                }

            } catch {
                print("❌ Person segmentation failed:", error)
                completion(nil)
            }
        }
    }
}
