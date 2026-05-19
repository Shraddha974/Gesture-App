//
//  SpeechRecognizer.swift
//  GestureApp
//
//  Created by Shraddha on 19/12/25.
//

import Foundation
import AVFAudio
import Speech

final class SpeechRecognizer {

    private let audioEngine = AVAudioEngine()
    private let request = SFSpeechAudioBufferRecognitionRequest()
    private let recognizer = SFSpeechRecognizer(locale: .init(identifier: "en-US"))
    private var task: SFSpeechRecognitionTask?

    func start(onResult: @escaping (String) -> Void) {

        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.record, mode: .measurement)
        try? session.setActive(true)

        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)

        input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            self.request.append(buffer)
        }


        audioEngine.prepare()
        try? audioEngine.start()

        task = recognizer?.recognitionTask(with: request) { result, _ in
            if let text = result?.bestTranscription.formattedString {
                onResult(text)
            }
        }
    }

    func stop() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request.endAudio()
        task?.cancel()
    }
}

final class WakeWordEngine {

    let wakeWord = "hey nova"

    func detect(_ text: String) -> Bool {
        text.lowercased().contains(wakeWord)
    }
}
