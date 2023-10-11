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

    @Published var accessAuthorized = HeadphoneMotionDetector.isAuthorized()

    var headphoneMotionDetector = HeadphoneMotionDetector(updateInterval: 0.01)
    var oscSender = OSCSender()

    let quaternionUpdate = PassthroughSubject<Void, Never>()

    init() {
        headphoneMotionDetector.onUpdate = { [self] in
            quaternion = self.headphoneMotionDetector.quaternion
            correctedQuaternion = self.headphoneMotionDetector.correctedQuaternion
            scene.setQuaternion(q: self.correctedQuaternion)

            quaternionUpdate.send()

            oscSender.setQuaternion(q: correctedQuaternion)
        }

        headphoneMotionDetector.start()
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
    func applicationDidFinishLaunching(_: Notification) {
        // Initialize any setup here if needed
    }

    func applicationWillTerminate(_: Notification) {
        // Handle app termination here
    }

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        return true
    }
}
