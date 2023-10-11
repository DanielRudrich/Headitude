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

    @Published var data: CMDeviceMotion = .init()
    @Published var quaternion: CMQuaternion = .init()
    @Published var correctedQuaternion: CMQuaternion = .init()
    @Published var connected: Bool = false

    // calibration
    private var idleGravity: CMAcceleration = .init()
    private var idleQuaternion: CMQuaternion = CMQuaternion(x:0, y:0, z: 0, w: 1)
    private var idleQuaternionConjugated: CMQuaternion = CMQuaternion(x:0, y:0, z: 0, w: 1)
    private var calibration: CMQuaternion = CMQuaternion(x:0, y:0, z: 0, w: 1)

    func correctQuaternion() {
        let steering = idleQuaternionConjugated * quaternion
        correctedQuaternion = calibration.conjugated * steering * calibration
    }

    func resetOrientation() {
        idleQuaternionConjugated = quaternion.conjugated
    }

    func startCalibration() {
        idleGravity = data.gravity.copy()
        resetOrientation()
    }

    func finishCalibration() {
        // compute Rudrich'sche look-and-nod calibration
        let z = idleGravity.scaled(-1).normalized()
        let x = data.gravity.crossProduct(idleGravity.scaled(-1)).normalized()
        let y = z.crossProduct(x).normalized()

        let w = 0.5 * sqrt(1.0 + x.x + y.y + z.z)
        let f = 1 / (4 * w)

        calibration = CMQuaternion(x: f * (y.z - z.y), y: f * (z.x - x.z), z: f * (x.y - y.x), w: w)
    }

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
            self.data = data
            quaternion = data.attitude.quaternion
            correctQuaternion()
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
