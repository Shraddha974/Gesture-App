//
//  calendarFrameView.swift
//  GestureApp
//
//  Created by Shraddha on 12/01/26.
//

import SwiftUI

struct CalendarFrameView: View {

    let photo: UIImage

    var body: some View {
        ZStack {

            // 🔹 Background calendar image
            Image("calendar_2026_feb")
                .resizable()
                .scaledToFit()

            // 🔹 Photo inserted in middle
            Image(uiImage: photo)
                .resizable()
                .scaledToFill()
                .frame(
                    width: 260,   // 👈 adjust once
                    height: 150   // 👈 adjust once
                )
                .clipped()
                .cornerRadius(12)
                .offset(y: -10) // 👈 fine-tune vertical position
        }
        .frame(maxWidth: .infinity)
    }
}
