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
    /** Raw quaternion from sensor. */
    @Published var rawQuaternion = CMQuaternion()

    /** Corrected quaternion using calibration. */
    @Published var quaternion = CMQuaternion()

    @AppStorage("AppState.calibration") private var calibration: Data = .init()

    private var accessCheckTimer = Timer()
    @Published var accessAuthorized = HeadphoneMotionDetector.isAuthorized()

    var headphoneMotionDetector = HeadphoneMotionDetector()
    var oscSender = OSCSender()

    init() {
        headphoneMotionDetector.onUpdate = { [self] in
            rawQuaternion = self.headphoneMotionDetector.data.attitude.quaternion
            quaternion = self.headphoneMotionDetector.correctedQuaternion

            oscSender.setQuaternion(q: quaternion)
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
            ContentView().environmentObject(appState).fixedSize().preferredColorScheme(.dark)
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
