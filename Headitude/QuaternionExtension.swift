//
//  QuaternionExtension.swift
//  Headitude
//
//  Created by Daniel Rudrich on 07.10.23.
//

import CoreMotion
import Foundation
import SceneKit

struct TaitBryan {
    var yaw: Double
    var pitch: Double
    var roll: Double
}

extension CMQuaternion: Equatable {
    public static func == (lhs: CMQuaternion, rhs: CMQuaternion) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z && lhs.w == rhs.w
    }

    var angle: Double {
        return acos(w) * 2
    }

    var axis: SCNVector3 {
        let length = sqrt(1 - w * w)
        if length < 0.001 {
            return SCNVector3(1, 0, 0)
        }
        return SCNVector3(x / length, y / length, z / length)
    }

    static func * (a: CMQuaternion, b: CMQuaternion) -> CMQuaternion {
        return CMQuaternion(
            x: a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
            y: a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,
            z: a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w,
            w: a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z
        )
    }

    var inverse: CMQuaternion {
        return CMQuaternion(x: -x, y: -y, z: -z, w: w)
    }

    func toAmbisonicCoordinateSystem() -> CMQuaternion {
        return CMQuaternion(x: y, y: -x, z: z, w: w)
    }

    /**
     * Convert a quaternion to Tait-Bryan angles (yaw, pitch, roll).
     * Note: only valid if this quaternion represents the Ambisonic coordinate system.
     */
    func toTaitBryan() -> TaitBryan {
        let yaw = atan2(
            2 * (w * z + x * y), 1 - 2 * (y * y + z * z)
        )
        let pitch = asin(2 * min(max(w * y - z * x, -1), 1))
        let roll = atan2(
            2 * (w * x + y * z), 1 - 2 * (x * x + y * y)
        )
        return TaitBryan(yaw: yaw, pitch: pitch, roll: roll)
    }

    static func * (a: CMQuaternion, b: SCNVector3) -> SCNVector3 {
        let p = CMQuaternion(x: b.x, y: b.y, z: b.z, w: 0)
        let q = a * p * a.inverse
        return SCNVector3(q.x, q.y, q.z)
    }
}
