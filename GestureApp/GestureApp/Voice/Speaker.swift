//
//  Speaker.swift
//  GestureApp
//
//  Created by Shraddha on 19/12/25.
//

import Foundation
import AVFAudio

final class Speaker {

    private let synth = AVSpeechSynthesizer()

    func speak(_ text: String, onFinish: (() -> Void)? = nil) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.45

        synth.speak(utterance)

        if let onFinish {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onFinish()
            }
        }
    }
}
