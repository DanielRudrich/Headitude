//
//  HeadphoneMotionDetector.swift
//  Headitude
//
//  Created by Daniel Rudrich on 06.10.23.
//

import Cocoa
import CoreMotion
import Foundation
import SwiftUI

class HeadphoneMotionDetector: NSObject, ObservableObject, CMHeadphoneMotionManagerDelegate {
    @Published var data: CMDeviceMotion = .init()
    @Published var correctedQuaternion: CMQuaternion = .init()
    @Published var userAcceleration: CMAcceleration = .init()
    @Published var connected: Bool = false

    private let headphoneMotionManager = CMHeadphoneMotionManager()
    let calibration = Calibration()

    override init() {
        super.init()

        headphoneMotionManager.delegate = self
    }

    var onUpdate: (() -> Void) = {}
    var onConnectionStatusChanged: ((_ isConnected: Bool) -> Void) = { _ in }

    static var authorizationStatus: CMAuthorizationStatus {
        return CMHeadphoneMotionManager.authorizationStatus()
    }

    static func isAuthorized() -> Bool {
        return CMHeadphoneMotionManager.authorizationStatus() == CMAuthorizationStatus.authorized
    }

    func start() {
        if headphoneMotionManager.isDeviceMotionAvailable {
            if !headphoneMotionManager.isDeviceMotionActive {
                headphoneMotionManager.startDeviceMotionUpdates(to: .main) { motionData, error in
                    guard error == nil else {
                        print(error!)
                        return
                    }

                    if let motionData = motionData {
                        self.data = motionData
                        self.calibration.update(data: motionData)
                        self.userAcceleration = motionData.userAcceleration;
                        self.correctedQuaternion = self.calibration.apply(to: motionData.attitude.quaternion)
                        self.onUpdate()
                    }
                }
            }
        } else {
            print("Motion data is not available on this device.")
        }
    }

    func stop() {
        headphoneMotionManager.stopDeviceMotionUpdates()
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
