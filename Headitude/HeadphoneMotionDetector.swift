//
//  HeadphoneMotionDetector.swift
//  Headitude
//
//  Created by Daniel Rudrich on 06.10.23.
//

import Cocoa
import CoreMotion
import Foundation

class HeadphoneMotionDetector: NSObject, ObservableObject, CMHeadphoneMotionManagerDelegate {
    private let headphoneMotionManager = CMHeadphoneMotionManager()

    private var timer = Timer()
    private var updateInterval: TimeInterval

    @Published var quaternion: CMQuaternion = .init()

    @Published var connected: Bool = false

    var onUpdate: (() -> Void) = {}
    var onConnectionStatusChanged: ((_ isConnected: Bool) -> Void) = { _ in }

    static func isAuthorized() -> Bool {
        return CMHeadphoneMotionManager.authorizationStatus() == CMAuthorizationStatus.authorized
    }

    init(updateInterval: TimeInterval) {
        self.updateInterval = updateInterval
        super.init()

        headphoneMotionManager.delegate = self
    }

    func start() {
        if headphoneMotionManager.isDeviceMotionAvailable {
            if !headphoneMotionManager.isDeviceMotionActive {
                // Request access to motion data
                headphoneMotionManager.startDeviceMotionUpdates()

                // Check for access
                if CMHeadphoneMotionManager.authorizationStatus() == CMAuthorizationStatus.authorized {
                    // You have access to motion data
                    print("Motion data is available.")
                } else {
                    // User denied access, provide instructions to grant access manually
                    print("Motion data access not given.")
                }
            }
        } else {
            // Motion data is not available on this device
            print("Motion data is not available on this device.")
        }

        if headphoneMotionManager.isDeviceMotionAvailable {
            headphoneMotionManager.startDeviceMotionUpdates()

            timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
                self.updateMotionData()
            }
        } else {
            print("Device motion not available")
        }
    }

    func updateMotionData() {
        if let data = headphoneMotionManager.deviceMotion {
            quaternion = data.attitude.quaternion
            onUpdate()
        }
    }

    func stop() {
        headphoneMotionManager.stopDeviceMotionUpdates()
        timer.invalidate()
    }

    deinit {
        stop()
    }

    func headphoneMotionManagerDidConnect(_: CMHeadphoneMotionManager) {
        print("Headphones connected")
        connected = true
        onConnectionStatusChanged(connected)
    }

    func headphoneMotionManagerDidDisconnect(_: CMHeadphoneMotionManager) {
        print("headphones disconnected")
        connected = false
        onConnectionStatusChanged(connected)
    }
}
