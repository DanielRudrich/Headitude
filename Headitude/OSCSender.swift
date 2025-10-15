//
//  OSCSender.swift
//  Headitude
//
//  Created by Daniel Rudrich on 08.10.23.
//

import CoreMotion
import OSCKit
import SwiftUI

struct OSCStorageType: Codable {
    var ip: String
    var port: UInt16
    var oscProtocol: String
}

class OSCSender: ObservableObject {
    private var client = OSCClient()

    private var quaternion: CMQuaternion = .init()
    private var acceleration: CMAcceleration = .init();

    @AppStorage("oscSettings") var oscSettingsStore: Data = .init()

    @Published var oscProtocol = "/SceneRotator/ypr yaw pitch roll"
    @Published var ip = "localhost"
    @Published var port: UInt16 = 3001
    @Published var protocolValid = true

    init() {
        restoreSettings()
    }

    func restoreSettings() {
        guard let decoded = try? JSONDecoder().decode(OSCStorageType.self, from: oscSettingsStore) else { return }
        oscProtocol = decoded.oscProtocol
        ip = decoded.ip
        port = decoded.port
    }

    func storeSettings() {
        let oscSettingsData = OSCStorageType(ip: ip, port: port, oscProtocol: oscProtocol)
        guard let data = try? JSONEncoder().encode(oscSettingsData) else { return }
        oscSettingsStore = data
    }
    
    func setAcceleration(a: CMAcceleration) {
        acceleration = a;
    }

    func setQuaternion(q: CMQuaternion) {
        quaternion = q.toAmbisonicCoordinateSystem()
        let taitBryan = quaternion.toTaitBryan()

        let protocolParts = oscProtocol.components(separatedBy: " ")
        let protocolPartsFiltered = protocolParts.filter { !$0.isEmpty }

        let address = protocolPartsFiltered[0]

        var values: OSCValues = []

        for i in 1 ..< protocolPartsFiltered.count {
            var part = protocolPartsFiltered[i]

            var factor: Float = 1.0

            if part.starts(with: "-") {
                factor = -1.0
                part = String(part.dropFirst())
            }

            var value = 0.0

            switch part {
            case "yaw":
                value = rad2deg(taitBryan.yaw)
            case "yaw+":
                value = rad2deg(taitBryan.yaw)
                if value < 0 { value += 360 }
            case "pitch":
                value = rad2deg(taitBryan.pitch)
            case "pitch+":
                value = rad2deg(taitBryan.pitch)
                if value < 0 { value += 360 }
            case "roll":
                value = rad2deg(taitBryan.roll)
            case "roll+":
                value = rad2deg(taitBryan.roll)
                if value < 0 { value += 360 }

            case "yawRad":
                value = taitBryan.yaw
            case "yawRad+":
                value = taitBryan.yaw
                if value < 0 { value += 2 * .pi }
            case "pitchRad":
                value = taitBryan.pitch
            case "pitchRad+":
                value = taitBryan.pitch
                if value < 0 { value += 2 * .pi }
            case "rollRad":
                value = taitBryan.roll
            case "rollRad+":
                value = taitBryan.roll
                if value < 0 { value += 2 * .pi }

            case "qw":
                value = quaternion.w
            case "qx":
                value = quaternion.x
            case "qy":
                value = quaternion.y
            case "qz":
                value = quaternion.z
            
            case "accx":
                value = acceleration.x
            case "accy":
                value = acceleration.y
            case "accz":
                value = acceleration.z

            default:
                if protocolValid { protocolValid = false }
                return
            }

            values.append(factor * Float(value))
        }

        if !protocolValid { protocolValid = true }

        let msg = OSCMessage(address, values: values)
        do {
            try client.send(msg, to: ip, port: port)
        } catch {
            print("failed osc")
        }
    }
}

struct OSCSenderView: View {
    @State private var isIPPopoverVisible = false
    @State private var isMessagePopoverVisible = false

    @ObservedObject var oscSender: OSCSender

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("OSC Settings ").font(.system(size: 20, weight: .light)).foregroundStyle(Color(hex: 0xACACAC))
            HStack {
                HStack {
                    Text("Host / IP")
                        .font(.headline)
                        .foregroundColor(.blue)

                    Button(action: {
                        isIPPopoverVisible.toggle()
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .popover(isPresented: $isIPPopoverVisible, arrowEdge: .bottom) {
                        VStack {
                            Text("The IP-address or hostname of the OSC destination.")
                            Text("e.g. localhost or 127.0.0.1")
                        }.padding()
                    }

                    TextField("e.g., 127.0.0.1", text: $oscSender.ip)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                HStack {
                    Text("Port")
                        .font(.headline)
                        .foregroundColor(.blue)
                    TextField("e.g., 8080", value: $oscSender.port, formatter: NumberFormatter.integer)
                        .textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: 80)
                }
            }

            HStack {
                Text("Message")
                    .font(.headline)
                    .foregroundColor(.blue)
                Button(action: {
                    isMessagePopoverVisible.toggle()
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
                .popover(isPresented: $isMessagePopoverVisible, arrowEdge: .bottom) {
                    VStack {
                        Text("The OSC Message pattern, starting with an address and then space-delimited tokens.")
                        Text("e.g. /SceneRotator/ypr yaw pitch roll")
                    }.padding()
                }

                TextField("e.g., http://", text: $oscSender.oscProtocol)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .background(oscSender.protocolValid ? Color.clear : Color.red)
                    .cornerRadius(4)
            }
        }
        .padding(10)
        .background(Color(hex: 0x252525)).cornerRadius(8)
        .padding()
        .shadow(radius: 10)
        .onDisappear {
            // I don't think that's the right place to store the settings, but it works for now.
            oscSender.storeSettings()
        }
    }
}

extension NumberFormatter {
    static var integer: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.thousandSeparator = ""
        return formatter
    }
}

struct InfoButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "info.circle")
                .foregroundColor(.blue)
                .font(.system(size: 12))
        }
    }
}

#Preview {
    OSCSenderView(oscSender: OSCSender()).frame(width: 400)
}
