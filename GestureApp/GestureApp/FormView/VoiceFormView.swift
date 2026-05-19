//
//  VoiceFormView.swift
//  GestureApp
//
//  Created by Shraddha on 22/12/25.
//

import SwiftUI

struct VoiceFormView: View {

    @StateObject private var form = FormViewModel()
    @StateObject private var assistant: FormVoiceAssistant

    init() {
        let f = FormViewModel()
        _form = StateObject(wrappedValue: f)
        _assistant = StateObject(wrappedValue: FormVoiceAssistant(form: f))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {

                Text("Voice Powered Form")
                    .font(.largeTitle.bold())

                PremiumField(title: "Name", icon: "person.fill", text: $form.name)
                PremiumField(title: "Email", icon: "envelope.fill", text: $form.email)
                PremiumField(title: "Phone", icon: "phone.fill", text: $form.phone)
                PremiumField(title: "Age", icon: "calendar", text: $form.age)

                PremiumCommentBox(text: $form.comment)

                Text("🎙️ \(assistant.transcript)")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                VoiceButton(listening: assistant.listening) {
                    assistant.listening ? assistant.stop() : assistant.start()
                }

                SubmitButton {
                    submitForm()
                }
            }
            .padding()
        }
    }

    private func submitForm() {
        print(form.summary())
    }
}

struct SubmitButton: View {

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Submit")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(colors: [.trelleborgGold, .trelleborgGraphite],
                                   startPoint: .leading,
                                   endPoint: .trailing)
                )
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(radius: 12)
        }
    }
}
