//
//  ContentView.swift
//  Headitude
//
//  Created by Daniel Rudrich on 06.10.23.
//

import Cocoa
import CoreMotion
import OSCKit
import SwiftUI

struct ContentView: View {
    var appState: AppState

    @Binding var accessAuthorized: Bool

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 4) {
                Image(.logo)
                    .shadow(radius: 10)
                Text("Headitude")
                    .font(.system(size: 30))
                    .fontWeight(.light)
                    .foregroundColor(.white)
            }

            if !accessAuthorized {
                AccessInfo().padding()
            } else {
                HStack {
                    RotationViewerGroup(appState: appState).frame(width: 200)
                    ConnectionCalibrationView(appState: appState).frame(minWidth: 120)
                }

                OSCSenderView(oscSender: appState.oscSender).frame(width: 400)
            }
        }
        .padding()
        .background(Color(hex: 0x191919))
    }
}

#Preview {
    ContentView(appState: AppState(), accessAuthorized: .constant(true))
}

struct AccessInfo: View {
    var body: some View {
        VStack {
            Text("Access to motion data is required.")
                .fontWeight(.bold)

            Text(
                "Please go to System Preferences > Security & Privacy > Motion & Fitness to grant access to this app."
            ).fixedSize(horizontal: false, vertical: true)

            Button(action: {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy") {
                    NSWorkspace.shared.open(url)
                }

            }) {
                Text("Open Settings")
                    .fontWeight(.bold)
            }
        }.padding().background(.red.opacity(0.2)).cornerRadius(5).frame(maxWidth: 400).padding()
    }
}
