//
//  InspectionFormView.swift
//  GestureApp
//
//  Created by Shraddha on 05/01/26.
//

import SwiftUI

struct InspectionFormView: View {

    @State var data: InspectionData

    var body: some View {
        Form {
            Section("Equipment Details") {
                TextField("Model", text: $data.model)
                TextField("Serial Number", text: $data.serialNumber)
                TextField("Install Date", text: $data.installDate)
                TextField("Location", text: $data.location)
            }

            Button("Submit Inspection") {
                print("Submitted:", data)
            }
        }
        .navigationTitle("Inspection Form")
    }
}
