//
//  RotationViewer.swift
//  Headitude
//
//  Created by Daniel Rudrich on 07.10.23.
//

import CoreMotion
import SceneKit
import SwiftUI

struct RotationViewer: NSViewRepresentable {
    var scene: HeadScene

    func makeNSView(context _: Context) -> SCNView {
        // set up scene
        let sceneView = SCNView()

        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = false

        sceneView.backgroundColor = NSColor.clear

        return sceneView
    }

    func updateNSView(_: SCNView, context _: Context) {}
}

struct RotationViewerGroup: View {
    var appState: AppState

    @StateObject private var scene = HeadScene()
    @State private var mirrored = true

    var body: some View {
        VStack(spacing: 0) {
            RotationViewer(scene: scene).frame(width: 180, height: 120)
                .shadow(color: .black, radius: 20)
                .onReceive(appState.$quaternion) {
                    quaternion in scene.setQuaternion(quaternion)
                }
                .onChange(of: appState.quaternion) { _, quaternion in scene.setQuaternion(quaternion) }

            Text(mirrored ? "Mirrored" : "Normal view").font(.footnote).foregroundColor(.gray)
            Button("Toggle View") {
                scene.toggleMirrored()
                self.mirrored = scene.mirrored
            }
        }
    }
}
