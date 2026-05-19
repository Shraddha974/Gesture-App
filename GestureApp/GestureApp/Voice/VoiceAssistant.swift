//
//  VoiceAssistant.swift
//  GestureApp
//
//  Created by Shraddha on 19/12/25.
//


import Foundation
import AVFoundation
import Speech
import NaturalLanguage
import Combine

@MainActor
final class VoiceAssistant: ObservableObject {
    
    static let shared = VoiceAssistant()
    
    @Published var transcript = ""
    @Published var isListening = false
    @Published var assistantState: State = .idle
    
    enum State {
        case idle, listening, processing, speaking
    }
    
    private let recognizer = SpeechRecognizer()
    private let speaker = Speaker()
    private let intentEngine = IntentEngine()
    
    private init() {}
    
    func start() {
        assistantState = .listening
        recognizer.start { [weak self] text in
            self?.transcript = text
            self?.handle(text)
        }
        isListening = true
    }
    
    func stop() {
        recognizer.stop()
        isListening = false
        assistantState = .idle
    }
    
    private func handle(_ text: String) {
        assistantState = .processing
        let response = intentEngine.process(text)
        speak(response)
    }
    
    private func speak(_ response: String) {
        assistantState = .speaking
        speaker.speak(response) { [weak self] in
            self?.assistantState = .listening
        }
    }
}

@MainActor
final class FormVoiceAssistant: ObservableObject {
    
    @Published var transcript = ""
    @Published var listening = false
    
    private let recognizer = SpeechRecognizer()
    private let parser = VoiceCommandParser()
    private let speaker = Speaker()
    let form: FormViewModel
    
    init(form: FormViewModel) {
        self.form = form
    }
    
    func start() {
        listening = true
        recognizer.start { [weak self] text in
            guard let self else { return }
            self.transcript = text
            self.parser.handle(text: text, form: self.form, speaker: self.speaker)
        }
    }
    
    func stop() {
        listening = false
        recognizer.stop()
        speaker.speak("Stopped listening")
    }
}
