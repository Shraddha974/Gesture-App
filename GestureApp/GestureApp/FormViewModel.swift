//
//  FormViewModel.swift
//  GestureApp
//
//  Created by Shraddha on 22/12/25.
//

import SwiftUI
import Combine

@MainActor
final class FormViewModel: ObservableObject {

    @Published var name = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var age = ""
    @Published var comment = ""

    func clearAll() {
        name = ""
        email = ""
        phone = ""
        age = ""
        comment = ""
    }

    func summary() -> String {
        """
        Name: \(name)
        Email: \(email)
        Phone: \(phone)
        Age: \(age)
        Comment: \(comment)
        """
    }
}
