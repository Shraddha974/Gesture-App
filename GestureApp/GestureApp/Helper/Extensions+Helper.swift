//
//  Extensions+Helper.swift
//  GestureApp
//
//  Created by Shraddha on 12/01/26.
//

import Foundation
import SwiftUI

extension Color {
    static let trelleborgGold = Color(red: 0.600, green: 0.510, blue: 0.259)
    static let trelleborgBlack = Color.black
    static let trelleborgGraphite = Color(white: 0.15)
}

import CoreImage
import CoreImage.CIFilterBuiltins

func generateQRCode(from string: String) -> UIImage? {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    filter.message = Data(string.utf8)
    filter.correctionLevel = "Q"

    guard let outputImage = filter.outputImage else { return nil }

    let scaled = outputImage.transformed(
        by: CGAffineTransform(scaleX: 12, y: 12)
    )

    if let cgImage = context.createCGImage(scaled, from: scaled.extent) {
        return UIImage(cgImage: cgImage)
    }

    return nil
}

