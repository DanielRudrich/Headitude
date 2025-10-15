import SwiftUI
import CoreMotion

struct ConnectionView: View {
    var appState: AppState

    @State private var yawInDegrees = 0.0
    @State private var pitchInDegrees = 0.0
    @State private var rollInDegrees = 0.0
    
    @State private var acceleration: CMAcceleration = .init();

    @State private var connected = true
    var body: some View {
        VStack {
            Text(connected ? "Connected" : "Not Connected")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(connected ? Color.green : Color.red)

            HStack {
                Text("Yaw:").foregroundColor(.gray)
                Text(String(format: "%.1f°", yawInDegrees)).foregroundColor(.gray).frame(width: 50)
            }

            HStack {
                Text("Pitch:").foregroundColor(.gray)
                Text(String(format: "%.1f°", pitchInDegrees)).foregroundColor(.gray).frame(width: 50)
            }

            HStack {
                Text("Roll:").foregroundColor(.gray)
                Text(String(format: "%.1f°", rollInDegrees)).foregroundColor(.gray).frame(width: 50)
            }
            HStack {
                Text("Acc X:").foregroundColor(.gray)
                Text(String(format: "%.2f G", acceleration.x)).foregroundColor(.gray).frame(width: 50)
            }
            HStack {
                Text("Acc Y:").foregroundColor(.gray)
                Text(String(format: "%.2f G", acceleration.y)).foregroundColor(.gray).frame(width: 50)
            }
            HStack {
                Text("Acc Z:").foregroundColor(.gray)
                Text(String(format: "%.2f G", acceleration.z)).foregroundColor(.gray).frame(width: 50)
            }
        }
        .onReceive(appState.headphoneMotionDetector.$connected) {
            newState in connected = newState
        }
        .onReceive(
            appState.$quaternion.throttle(for: 0.10, scheduler: RunLoop.main, latest: true)
        ) { newRotation in
            let quaternion = newRotation.toAmbisonicCoordinateSystem()
            let taitBryan = quaternion.toTaitBryan()

            yawInDegrees = rad2deg(taitBryan.yaw)
            pitchInDegrees = rad2deg(taitBryan.pitch)
            rollInDegrees = rad2deg(taitBryan.roll)
        }
        .onReceive(
            appState.$acceleration.throttle(for: 0.10, scheduler: RunLoop.main, latest: true)
        ) { newAcceleration in
            acceleration = newAcceleration
        }
    }
}

struct ConnectionCalibrationView: View {
    var appState: AppState

    var body: some View {
        VStack {
            ConnectionView(appState: appState)

            Button(action: {
                appState.headphoneMotionDetector.calibration.resetOrientation()
            }) {
                Text("Reset Orientation")
            }

            PressedReleaseButton(buttonText: "Full Calibration", onDown: { appState.headphoneMotionDetector.calibration.start() }, onRelease: { appState.headphoneMotionDetector.calibration.finish() })
            Text("Press, nod, release to calibrate")
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }
}

struct PressedReleaseButton: View {
    @GestureState private var pressed = false
    @State private var pressing = false

    let buttonText: String
    var onDown: () -> Void
    var onRelease: () -> Void

    var body: some View {
        Text(buttonText)
            .padding(4)
            .background(self.pressing ? Color.red : Color.blue)
            .cornerRadius(6)

            .gesture(DragGesture(minimumDistance: 0.0)
                .onChanged { _ in
                    if !self.pressing {
                        self.pressing = true
                        onDown()
                    }
                }
                .onEnded { _ in
                    self.pressing = false
                    onRelease()
                })
    }
}
