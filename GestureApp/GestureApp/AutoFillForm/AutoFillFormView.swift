//
//  AutoFillFormView.swift
//  GestureApp
//
//  Created by Shraddha on 05/01/26.
//

import SwiftUI

struct AutoFillFormView: View {
    
    @State private var detectedText = ""
    @State private var parsedData: InspectionData?
    @State private var showForm = false
    @State private var resetScanner = UUID()
    
    var body: some View {
        NavigationStack {
            VStack {
                LiveCameraTextScanner(
                    resetID: resetScanner
                ) { text in
                    detectedText = text
                }
                .frame(height: 580)
                
                Button("Extract & Fill Form") {
                    guard TextValidator.isValidInspectionText(detectedText) else {
                        print("Invalid scan, ignoring")
                        return
                    }
                    
                    print("FINAL TEXT USED FOR PARSING:\n\(detectedText)")
                    
                    parsedData = TextParser.parse(detectedText)
                    print("PARSED DATA:", parsedData!)
                    
                    showForm = true
                }
                .padding()
                .buttonStyle(.borderedProminent)
                
                .onAppear {
                    detectedText = ""
                    parsedData = nil
                    resetScanner = UUID()
                }
                
            }
            .navigationTitle("Scan Equipment")
            .navigationDestination(isPresented: $showForm) {
                if let data = parsedData {
                    InspectionFormView(data: data)
                }
            }
        }
    }
    
}

#Preview {
    AutoFillFormView()
}
