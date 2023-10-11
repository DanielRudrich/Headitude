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

    @State private var yaw = 0.0
    @State private var pitch = 0.0
    @State private var roll = 0.0
    @Binding var connected: Bool

    var body: some View {
        VStack {
            Text("Headitude")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(.blue)
                .padding()

            if !appState.accessAuthorized {
                AccessInfo()
            } else {
                HStack {
                    VStack(spacing: 0) {
                        RotationViewer(scene: $appState.scene).frame(width: 180, height: 120)
                        Button("Toggle Mirrored") {
                            appState.scene.toggleMirrored()
                        }
                    }

                    VStack {
                        Text(connected ? "Connected" : "Not Connected")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(connected ? Color.green : Color.red)

                        HStack {
                            Text("Yaw:")
                            Text(String(format: "%.2f", yaw))
                        }

                        HStack {
                            Text("Pitch:")
                            Text(String(format: "%.2f", pitch))
                        }

                        HStack {
                            Text("Roll:")
                            Text(String(format: "%.2f", roll))
                        }
                        
                        Button(action: {
                            appState.headphoneMotionDetector.resetOrientation()
                                }) {
                                    Text("reset")
                                }
                        
                        Button(action: {
                            appState.headphoneMotionDetector.startCalibration()
                                }) {
                                    Text("Start")
                                }
                              
                        Button(action: {
                            appState.headphoneMotionDetector.finishCalibration()
                                }) {
                                    Text("end")
                                }
                                
                    }.frame(minWidth: 120)
                }

                OSCSenderView(oscSender: $appState.oscSender, isValid: $appState.oscSender.protocolValid).frame(width: 400)
            }
        }
        .onChange(of: appState.quaternion) { _, newRotation in
            let quaternion = newRotation.toAmbisonicCoordinateSystem()
            let taitBryan = quaternion.toTaitBryan()

            yaw = taitBryan.yaw
            pitch = taitBryan.pitch
            roll = taitBryan.roll
        }
    }
}

#Preview {
    ContentView(connected: .constant(false)).environmentObject(AppState())
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
        }.padding().background(.red.opacity(0.2)).cornerRadius(5)
    }
}
