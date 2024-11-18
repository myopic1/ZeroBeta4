//
//  CloudKitDebugView.swift
//  ZeroBeta4
//
//

import SwiftUI

struct CloudKitDebugView: View {
    var body: some View {
        VStack {
            Button("Test Save and Delete") {
                Task {
                    await CloudKitUtilityTest.testSaveAndDelete()
                }
            }
        }
        .padding()
        .navigationTitle("CloudKit Debug")
    }
}
