//
//  Utilities.swift
//  Headitude
//
//  Created by Daniel Rudrich on 22.10.23.
//

import Foundation
import SwiftUI

func rad2deg(_ number: Double) -> Double {
    return number * 180 / .pi
}

extension ShapeStyle where Self == Color {
    static var random: Color {
        Color(
            red: .random(in: 0 ... 1),
            green: .random(in: 0 ... 1),
            blue: .random(in: 0 ... 1)
        )
    }
}

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex & 0xFF0000) >> 16) / 255.0,
            green: Double((hex & 0x00FF00) >> 8) / 255.0,
            blue: Double(hex & 0x0000FF) / 255.0,
            opacity: alpha
        )
    }
}
