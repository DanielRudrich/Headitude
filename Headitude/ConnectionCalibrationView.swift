import SwiftUI

struct ConnectionCalibrationView: View {
    @EnvironmentObject private var appState: AppState

    @State private var yaw = 0.0
    @State private var pitch = 0.0
    @State private var roll = 0.0
    @Binding var connected: Bool

    @State private var calibration = Calibration()

    var body: some View {
        VStack {
            Text(connected ? "Connected" : "Not Connected")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(connected ? Color.green : Color.red)

            HStack {
                Text("Yaw:").foregroundColor(.gray)
                Text(String(format: "%.2f", yaw)).foregroundColor(.gray)
            }

            HStack {
                Text("Pitch:").foregroundColor(.gray)
                Text(String(format: "%.2f", pitch)).foregroundColor(.gray)
            }

            HStack {
                Text("Roll:").foregroundColor(.gray)
                Text(String(format: "%.2f", roll)).foregroundColor(.gray)
            }

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
        .onChange(of: appState.quaternion) { _, newRotation in
            let quaternion = newRotation.toAmbisonicCoordinateSystem()
            let taitBryan = quaternion.toTaitBryan()

            yaw = taitBryan.yaw
            pitch = taitBryan.pitch
            roll = taitBryan.roll
        }
    }
}
