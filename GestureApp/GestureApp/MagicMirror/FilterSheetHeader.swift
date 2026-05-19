//
//  FilterSheetHeader.swift
//  PlayCam
//
//  Created by Shraddha on 03/02/26.
//

import SwiftUI

struct FilterSheetHeader: View {
    let title: String
    let onRemove: () -> Void
    let onClose: () -> Void

    var body: some View {
        HStack {
            // ⬅️ Remove filter (LEFT)
            Button(action: onRemove) {
                Text("Remove")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
            }

            Spacer()

            // 🏷️ Title (CENTER)
            Text(title)
                .font(.headline)

            Spacer()

            // ❌ Close (RIGHT)
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
        .frame(height: 44)   // ⬅️ middle aligned vertically
    }
}

