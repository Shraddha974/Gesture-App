//
//  IntentEngine.swift
//  GestureApp
//
//  Created by Shraddha on 19/12/25.
//

import Foundation

final class IntentEngine {

    func process(_ text: String) -> String {
        let lower = text.lowercased()

        if lower.contains("open settings") {
            NotificationCenter.default.post(name: .openSettings, object: nil)
            return "Opening settings"
        }

        if lower.contains("what time") {
            return "It is \(currentTime())"
        }

        if lower.contains("who are you") {
            return "I am your personal assistant"
        }

        return "Sorry, I didn’t understand that"
    }

    private func currentTime() -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: Date())
    }
}



extension Notification.Name {
    static let openSettings = Notification.Name("openSettings")
    static let goBack = Notification.Name("goBack")
}
