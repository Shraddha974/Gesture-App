//
//  TextValidator.swift
//  RuleBasedParsing
//
//  Created by Shraddha on 16/12/25.
//

import Foundation

struct TextValidator {

    static func isValidInspectionText(_ text: String) -> Bool {
        let lower = text.lowercased()

        let requiredKeywords = [
            "model",
            "serial",
            "installed",
            "location"
        ]

        let matchCount = requiredKeywords.filter {
            lower.contains($0)
        }.count

        // At least 2 strong matches required
        return matchCount >= 2
    }
}
