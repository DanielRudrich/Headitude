//
//  Calibration.swift
//  Headitude
//
//  Created by Daniel Rudrich on 12.10.23.
//

import CoreMotion
import Foundation
import SwiftUI

struct CalibrationStorageType: Codable {
    var calibrationW: Double
    var calibrationX: Double
    var calibrationY: Double
    var calibrationZ: Double

    var idleW: Double
    var idleX: Double
    var idleY: Double
    var idleZ: Double
}

class Calibration {
    @AppStorage("calibration") var calibrationStore: Data = .init()

    private var data: CMDeviceMotion = .init()

    // calibration
    private var idleGravity: CMAcceleration = .init()
    private var idleQuaternion: CMQuaternion = .init(x: 0, y: 0, z: 0, w: 1)
    private var calibration: CMQuaternion = .init(x: 0, y: 0, z: 0, w: 1)

    init() {
        restoreCalibration()
    }

    deinit {
        storeCalibration()
    }

    func update(data: CMDeviceMotion) {
        self.data = data
    }

    func restoreCalibration() {
        guard let decoded = try? JSONDecoder().decode(CalibrationStorageType.self, from: calibrationStore) else { return }
        calibration = CMQuaternion(x: decoded.calibrationX, y: decoded.calibrationY, z: decoded.calibrationZ, w: decoded.calibrationW)
        idleQuaternion = CMQuaternion(x: decoded.idleX, y: decoded.idleY, z: decoded.idleZ, w: decoded.idleW)
    }

    func storeCalibration() {
        let calibrationData = CalibrationStorageType(calibrationW: calibration.w, calibrationX: calibration.x, calibrationY: calibration.y, calibrationZ: calibration.z, idleW: idleQuaternion.w, idleX: idleQuaternion.x, idleY: idleQuaternion.y, idleZ: idleQuaternion.z)
        guard let data = try? JSONEncoder().encode(calibrationData) else { return }
        calibrationStore = data
    }

    func apply(to: CMQuaternion) -> CMQuaternion {
        let steering = idleQuaternion * to
        let final = calibration.conjugated * steering * calibration
        return final
    }

    func resetOrientation() {
        idleQuaternion = data.attitude.quaternion.conjugated
    }

    func start() {
        idleGravity = data.gravity.copy()
        resetOrientation()
    }

    func finish() {
        // compute Rudrich'sche look-and-nod calibration
        let z = idleGravity.scaled(-1).normalized()
        let x = data.gravity.crossProduct(idleGravity.scaled(-1)).normalized()
        let y = z.crossProduct(x).normalized()

        let w = 0.5 * sqrt(1.0 + x.x + y.y + z.z)
        let f = 1 / (4 * w)

        calibration = CMQuaternion(x: f * (y.z - z.y), y: f * (z.x - x.z), z: f * (x.y - y.x), w: w)
        storeCalibration()
    }
}
