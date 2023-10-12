//
//  AccelerationExtension.swift
//  Headitude
//
//  Created by Daniel Rudrich on 09.10.23.
//

import CoreMotion
import Foundation

extension CMAcceleration {
    func crossProduct(_ other: CMAcceleration) -> CMAcceleration {
        return CMAcceleration(x: y * other.z - z * other.y,
                              y: z * other.x - x * other.z,
                              z: x * other.y - y * other.x)
    }

    func dotProduct(_ other: CMAcceleration) -> Double {
        return x * other.x + y * other.y + z * other.z
    }

    func magnitude() -> Double {
        return sqrt(x * x + y * y + z * z)
    }

    func normalized() -> CMAcceleration {
        let mag = magnitude()
        return CMAcceleration(x: x / mag, y: y / mag, z: z / mag)
    }

    func scaled(_ factor: Double) -> CMAcceleration {
        return CMAcceleration(x: x * factor, y: y * factor, z: z * factor)
    }

    func copy() -> CMAcceleration {
        return CMAcceleration(x: x, y: y, z: z)
    }
}
