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
    @EnvironmentObject private var appState: AppState

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

            if !appState.accessAuthorized {
                AccessInfo().padding()
            } else {
                HStack {
                    RotationViewerGroup().frame(width: 200)

                    ConnectionCalibrationView(connected: $appState.headphoneMotionDetector.connected).frame(minWidth: 120)
                }

                OSCSenderView(oscSender: $appState.oscSender, isValid: $appState.oscSender.protocolValid).frame(width: 400)
            }
        }
        .onDisappear {
            // I don't think that's the right place to store the settings, but it works for now.
            appState.oscSender.storeSettings()
        }
        .padding()
        .background(Color(hex: 0x191919))
    }
}

#Preview {
    ContentView().environmentObject(AppState())
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

struct PressedReleaseButton: View {
    @GestureState private var pressed = false
    @State private var pressing = false

    let buttonText: String
    var onDown: () -> Void
    var onRelease: () -> Void

    var body: some View {
        Text(buttonText)
            .padding(4)
            .background(self.pressing ? Color.red : Color.blue)
            .cornerRadius(6)

            .gesture(DragGesture(minimumDistance: 0.0)
                .onChanged { _ in
                    if !self.pressing {
                        self.pressing = true
                        onDown()
                    }
                }
                .onEnded { _ in
                    self.pressing = false
                    onRelease()
                })
    }
}

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex & 0xFF0000) >> 16) / 255.0,
            green: Double((hex & 0x00FF00) >> 8) / 255.0,
            blue: Double(hex & 0x0000FF) / 255.0,
            opacity: alpha
        )
    }
}
