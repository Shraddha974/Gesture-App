//
//  MagicMirror.swift
//  PhotoProbe
//
//  Created by Shraddha on 09/01/26.
//

import Foundation
import UIKit
import SwiftUI

//struct MagicMirrorView: UIViewControllerRepresentable {
//
//    @Binding var filters: Set<FaceFilter>
//    let onCapture: (UIImage) -> Void
//
//    func makeUIViewController(context: Context) -> FaceARViewController {
//        let vc = FaceARViewController()
//        vc.onImageCaptured = { image in
//            onCapture(image)
//        }
//        return vc
//    }
//    
//    func updateUIViewController(
//        _ uiViewController: FaceARViewController,
//        context: Context
//    ) {
//        uiViewController.updateFilters(filters)
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(onCapture: onCapture)
//    }
//
//    class Coordinator {
//        weak var controller: FaceARViewController?
//        let onCapture: () -> Void
//
//        init(onCapture: @escaping () -> Void) {
//            self.onCapture = onCapture
//        }
//
//        func capture() {
//            controller?.captureAndSaveToGallery()
//        }
//    }
//}
//


struct MagicMirrorView: UIViewControllerRepresentable {

    @Binding var filters: Set<FaceFilter>
    let onCapture: (UIImage) -> Void   

    func makeUIViewController(context: Context) -> FaceARViewController {
        let vc = FaceARViewController()
        vc.onImageCaptured = { image in
            onCapture(image)
        }
        return vc
    }

    func updateUIViewController(
        _ uiViewController: FaceARViewController,
        context: Context
    ) {
        uiViewController.updateFilters(filters)
    }
}
