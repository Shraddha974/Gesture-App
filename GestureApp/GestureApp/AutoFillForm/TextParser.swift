//
//  TextParser.swift
//  RuleBasedParsing
//
//  Created by Shraddha on 16/12/25.
//

import Foundation


final class TextParser {

    static func parse(_ text: String) -> InspectionData {
        var data = InspectionData()

        let lines = text.components(separatedBy: .newlines)

        for line in lines {
            let lower = line.lowercased()

            // Serial Number
            if lower.contains("serial") || lower.contains("sn") {
                data.serialNumber = extractValue(from: line)
            }

            // Model
            if lower.contains("model") {
                data.model = extractValue(from: line)
            }

            if lower.contains("installed") || lower.contains("date") {
                if let date = extractDate(from: line) {
                    data.installDate = date
                    //data.dateAuto = true
                }
            }


            // Location
            if lower.contains("location") {
                data.location = extractValue(from: line)
            }
        }

        return data
    }

    private static func extractValue(from line: String) -> String {
        line.components(separatedBy: ":")
            .last?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    private static func extractDate(from line: String) -> String? {
        let pattern = #"\b\d{1,2}/\d{1,2}/\d{2,4}\b"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(line.startIndex..., in: line)

        if let match = regex?.firstMatch(in: line, range: range),
           let resultRange = Range(match.range, in: line) {
            return String(line[resultRange])
        }
        return nil
    }
}
