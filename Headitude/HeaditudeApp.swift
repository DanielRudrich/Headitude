//
//  HeaditudeApp.swift
//  Headitude
//
//  Created by Daniel Rudrich on 06.10.23.
//

import Combine
import CoreMotion
import SwiftUI

class AppState: ObservableObject {
    /** Corrected quaternion using calibration. */
    @Published var quaternion = CMQuaternion()
    @Published var acceleration = CMAcceleration()

    @AppStorage("AppState.calibration") private var calibration: Data = .init()

    private var accessCheckTimer = Timer()
    @Published var accessAuthorized = HeadphoneMotionDetector.isAuthorized()

    var headphoneMotionDetector = HeadphoneMotionDetector()
    var oscSender = OSCSender()

    init() {
        headphoneMotionDetector.onUpdate = { [self] in
            quaternion = self.headphoneMotionDetector.correctedQuaternion
            oscSender.setQuaternion(q: quaternion)
            
            acceleration = self.headphoneMotionDetector.userAcceleration;
            oscSender.setAcceleration(a: acceleration)
        }

        headphoneMotionDetector.start()

        // repeatedly check if access has been granted by the user
        if !HeadphoneMotionDetector.isAuthorized() {
            if HeadphoneMotionDetector.authorizationStatus == CMAuthorizationStatus.notDetermined {
                accessCheckTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    self.accessAuthorized = HeadphoneMotionDetector.isAuthorized()
                    if HeadphoneMotionDetector.authorizationStatus != CMAuthorizationStatus.notDetermined {
                        self.accessCheckTimer.invalidate()
                    }
                }
            }
        }
    }
}

@main
struct HeaditudeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView(appState: appState, accessAuthorized: $appState.accessAuthorized).fixedSize().preferredColorScheme(.dark)
        }.windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {}

    func applicationWillTerminate(_: Notification) {}

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        return true
    }
}
