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
    @Binding var scene: HeadScene

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
