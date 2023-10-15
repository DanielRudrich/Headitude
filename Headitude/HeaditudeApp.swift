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
    @Published var quaternion = CMQuaternion()
    @Published var correctedQuaternion = CMQuaternion()
    @Published var scene = HeadScene()

    @AppStorage("AppState.calibration") private var calibration: Data = .init()

    private var accessCheckTimer = Timer()
    @Published var accessAuthorized = HeadphoneMotionDetector.isAuthorized()

    var headphoneMotionDetector = HeadphoneMotionDetector(updateInterval: 0.01)
    var oscSender = OSCSender()

    let quaternionUpdate = PassthroughSubject<Void, Never>()

    init() {
        headphoneMotionDetector.onUpdate = { [self] in
            quaternion = self.headphoneMotionDetector.data.attitude.quaternion
            correctedQuaternion = self.headphoneMotionDetector.correctedQuaternion
            scene.setQuaternion(q: self.correctedQuaternion)

            quaternionUpdate.send()

            oscSender.setQuaternion(q: correctedQuaternion)
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
            ContentView(connected: $appState.headphoneMotionDetector.connected).fixedSize().environmentObject(appState)
        }.windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {}

    func applicationWillTerminate(_: Notification) {
        // userDefaults.set(appState.calibration, forKey: "SavedAppStateKey")
    }

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        return true
    }
}
