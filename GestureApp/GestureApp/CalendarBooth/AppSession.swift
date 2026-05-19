//
//  AppSession.swift
//  GestureApp
//
//  Created by Shraddha on 13/01/26.
//

import Combine
import SwiftUI

final class AppSession: ObservableObject {
    @Published var cutoutImage: UIImage? = nil
    @Published var showCalendarInMirror: Bool = false
}
