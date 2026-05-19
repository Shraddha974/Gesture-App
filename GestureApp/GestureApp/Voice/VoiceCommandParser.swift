//
//  HomeView.swift
//  GestureApp
//
//  Created by Shraddha on 19/12/25.
//

import Foundation
import SwiftUI

final class VoiceCommandParser {

    func handle(
        text: String,
        form: FormViewModel,
        speaker: Speaker
    ) {

        let t = text.lowercased()

        // NAME
        if t.contains("name is") || t.contains("set name") {
            form.name = extract(after: ["name is", "set name"], from: t)
            speaker.speak("Name set")
            return
        }

        // EMAIL
        if t.contains("email is") {
            form.email = extract(after: ["email is"], from: t)
                .replacingOccurrences(of: " at ", with: "@")
                .replacingOccurrences(of: " dot ", with: ".")
            speaker.speak("Email updated")
            return
        }

        // PHONE
        if t.contains("phone") || t.contains("mobile") {
            form.phone = extractNumbers(from: t)
            speaker.speak("Phone number saved")
            return
        }

        // AGE
        if t.contains("age") {
            form.age = extractNumbers(from: t)
            speaker.speak("Age updated")
            return
        }

        // COMMENT
        if t.contains("comment") || t.contains("add comment") {
            form.comment = extract(after: ["comment", "add comment"], from: t)
            speaker.speak("Comment added")
            return
        }

        // CLEAR
        if t.contains("clear comment") {
            form.comment = ""
            speaker.speak("Comment cleared")
            return
        }

        // READ BACK
        if t.contains("read my details") {
            speaker.speak(form.summary())
            return
        }

        // SUBMIT
        if t.contains("submit") {
            speaker.speak("Form submitted successfully")
            return
        }
    }

    // MARK: - Helpers

    private func extract(after keywords: [String], from text: String) -> String {
        for key in keywords {
            if let range = text.range(of: key) {
                return text[range.upperBound...].trimmingCharacters(in: .whitespaces)
            }
        }
        return ""
    }

    private func extractNumbers(from text: String) -> String {
        text.filter { "0123456789".contains($0) }
    }
}
