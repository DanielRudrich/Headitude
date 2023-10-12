//
//  HeadScene.swift
//  Headitude
//
//  Created by Daniel Rudrich on 08.10.23.
//

import CoreMotion
import Foundation
import SceneKit

class HeadScene: SCNScene {
    private let headGroup = SCNNode()
    private let mirror = SCNNode()

    func setQuaternion(q: CMQuaternion) {
        headGroup.rotation.w = q.angle
        let axis = q.axis
        headGroup.rotation.x = axis.x
        headGroup.rotation.y = axis.z
        headGroup.rotation.z = -axis.y
    }

    func toggleMirrored() {
        mirror.scale.z *= -1
    }

    override init() {
        super.init()

        // create head
        let head = SCNNode()
        let headGeometry = SCNCapsule(capRadius: 1, height: 2.5)
        head.geometry = headGeometry
        headGeometry.firstMaterial?.diffuse.contents = NSColor(
            calibratedRed: 1, green: 1, blue: 1, alpha: 0.4
        )
        head.position = SCNVector3(x: 0, y: 0, z: 0)

        // left eye
        let leftEye = SCNNode()
        let leftEyeGeometry = SCNSphere(radius: 0.1)
        leftEye.geometry = leftEyeGeometry
        leftEyeGeometry.firstMaterial?.diffuse.contents = NSColor(
            calibratedRed: 0, green: 0, blue: 0, alpha: 1
        )
        leftEye.position = SCNVector3(x: 0.3, y: 0.4, z: -0.9)

        // right eye
        let rightEye = SCNNode()
        let rightEyeGeometry = SCNSphere(radius: 0.1)
        rightEye.geometry = rightEyeGeometry
        rightEyeGeometry.firstMaterial?.diffuse.contents = NSColor(
            calibratedRed: 0, green: 0, blue: 0, alpha: 1
        )
        rightEye.position = SCNVector3(x: -leftEye.position.x, y: leftEye.position.y, z: leftEye.position.z)

        // left ear
        let leftEar = SCNNode()
        let leftEarGeometry = SCNSphere(radius: 0.2)
        leftEar.geometry = leftEarGeometry
        leftEarGeometry.firstMaterial?.diffuse.contents = NSColor(
            calibratedRed: 1, green: 0.5, blue: 0.4, alpha: 1
        )
        leftEar.position = SCNVector3(x: 1, y: 0.2, z: 0)

        // right ear
        let rightEar = SCNNode()
        let rightEarGeometry = SCNSphere(radius: 0.2)
        rightEar.geometry = rightEarGeometry
        rightEarGeometry.firstMaterial?.diffuse.contents = NSColor(
            calibratedRed: 0.3, green: 0.5, blue: 0.4, alpha: 1
        )
        rightEar.position = SCNVector3(x: -leftEar.position.x, y: leftEar.position.y, z: leftEar.position.z)

        // nose
        let nose = SCNNode()
        let noseGeometry = SCNSphere(radius: 0.1)
        nose.geometry = noseGeometry
        noseGeometry.firstMaterial?.diffuse.contents = NSColor(
            calibratedRed: 0.3, green: 0.5, blue: 0.4, alpha: 1
        )
        nose.position = SCNVector3(x: 0, y: 0, z: -1)

        // mouth
        let mouth = SCNNode()
        let mouthGeometry = SCNCylinder(radius: 0.2, height: 0.05)
        mouth.geometry = mouthGeometry
        mouthGeometry.firstMaterial?.diffuse.contents = NSColor(
            calibratedRed: 0.8, green: 0.2, blue: 0.2, alpha: 1
        )
        mouth.scale.z = 0.2
        mouth.position = SCNVector3(x: 0, y: -0.5, z: -1)

        // add together

        let lightNode = SCNNode()

        // create a new light object
        let light = SCNLight()
        light.type = .omni
        // set the light's color to white
        light.color = NSColor.white
        lightNode.light = light
        // set the position of the light node
        lightNode.position = SCNVector3(x: 0, y: 5, z: 5)

        // add the light node to the scene
        rootNode.addChildNode(lightNode)
        headGroup.addChildNode(head)
        headGroup.addChildNode(leftEye)
        headGroup.addChildNode(rightEye)
        headGroup.addChildNode(leftEar)
        headGroup.addChildNode(rightEar)
        headGroup.addChildNode(nose)
        headGroup.addChildNode(mouth)

        // mirror
        mirror.addChildNode(headGroup)

        // set up scene
        rootNode.addChildNode(mirror)

        // set up camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 3) // Adjust camera position
        rootNode.addChildNode(cameraNode)

        // Set camera to look at the origin
        let constraint = SCNLookAtConstraint(target: rootNode)
        cameraNode.constraints = [constraint]
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}