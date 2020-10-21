//
//  ViewController.swift
//  arbanner
//
//  Created by Lee Brenner on 10/20/20.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    let updateQueue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier!).serialSCNQueue")
    let scaleFactor = CGFloat(0.0001)
    let baseZDepth = CGFloat(0.03)
    let duoScaleFactor = CGFloat(0.000025)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let refImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = refImages
        configuration.maximumNumberOfTrackedImages = 1
        
        // Run the view's session
        sceneView.session.run(configuration, options: ARSession.RunOptions(arrayLiteral: [.resetTracking, .removeExistingAnchors]))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOut(duration: 0.5),
            .removeFromParentNode()
            ])
    }
    
    func getMover(x: CGFloat, y: CGFloat, z: CGFloat, d: Double) -> SCNAction {
        let mover = SCNAction.move(to: SCNVector3(x, y, z), duration: d)
        mover.timingMode = .easeOut
        return mover
    }
    
    func getScaler(d: Double) -> SCNAction {
        let scaler = SCNAction.scale(to: 1.0, duration: d)
        scaler.timingMode = .easeOut
        return scaler
    }
    
    func getSpinner(degrees: Float, d: Double) -> SCNAction {
        let spinner = SCNAction.rotateTo(x: 0, y: CGFloat(GLKMathDegreesToRadians(degrees)), z: 0, duration: d, usesShortestUnitArc: false)
        spinner.timingMode = .easeOut
        return spinner
    }
    
    func getRotater(degrees: Float, d: Double) -> SCNAction {
        let rotater = SCNAction.rotateTo(x: 0, y: 0, z: CGFloat(GLKMathDegreesToRadians(degrees)), duration: d, usesShortestUnitArc: false)
        rotater.timingMode = .easeOut
        return rotater
    }
    
    func releaseTheBeetle(on rootNode: SCNNode, xOffset: CGFloat) {
        let beetleImage = UIImage(named: "Beetle")
        let beetlePlane = SCNPlane(width: beetleImage!.size.width * scaleFactor, height: beetleImage!.size.height * scaleFactor)
        let beetleNode = SCNNode(geometry: beetlePlane)
        beetleNode.geometry?.firstMaterial?.diffuse.contents = beetleImage
        beetleNode.position.y += 0.01
        beetleNode.scale.x = 1.1
        beetleNode.scale.y = 1.1
        beetleNode.opacity = 0
        rootNode.addChildNode(beetleNode)
        beetleNode.runAction(.sequence([
            .wait(duration: 1.0),
            .group([
                .fadeOpacity(to: 1.0, duration: 0.6),
                getMover(x: 0, y: 0.01, z: baseZDepth, d: 1),
                getScaler(d: 1)
                ]),
            .repeatForever(.sequence([
                .wait(duration: 3.0),
                getRotater(degrees: 4, d: 0.1),
                getRotater(degrees: -3, d: 0.075),
                getRotater(degrees: 2.5, d: 0.05),
                getRotater(degrees: -1, d: 0.03),
                getRotater(degrees: 0.0, d: 0.02),
                .wait(duration: 4.0),
                getRotater(degrees: -4, d: 0.1),
                getRotater(degrees: 3, d: 0.075),
                getRotater(degrees: -2.5, d: 0.05),
                getRotater(degrees: 1, d: 0.03),
                getRotater(degrees: 0.0, d: 0.02)
                ]))
            ])
        )
        
        var sourceImage = UIImage(named: "Banner_Top")
        let bannerTopPlane = SCNPlane(width: sourceImage!.size.width * scaleFactor, height: sourceImage!.size.height * scaleFactor)
        let bannerTopNode = SCNNode(geometry: bannerTopPlane)
        bannerTopNode.geometry?.firstMaterial?.diffuse.contents = sourceImage
        bannerTopNode.position.z += Float(baseZDepth) - 0.0085
        bannerTopNode.position.y = Float(beetleImage!.size.height * 0.55 * scaleFactor)
        bannerTopNode.scale.x = 0.0
        bannerTopNode.opacity = 0
        rootNode.addChildNode(bannerTopNode)
        bannerTopNode.runAction(.sequence([
            .wait(duration: 1.9),
            .group([
                .fadeOpacity(to: 1.0, duration: 0.3),
                getScaler(d: 0.6)
                ])
            ])
        )
        
        sourceImage = UIImage(named: "Banner_Bottom")
        let bannerBottomPlane = SCNPlane(width: sourceImage!.size.width * scaleFactor, height: sourceImage!.size.height * scaleFactor)
        let bannerBottomNode = SCNNode(geometry: bannerBottomPlane)
        bannerBottomNode.geometry?.firstMaterial?.diffuse.contents = sourceImage
        bannerBottomNode.position.z += Float(baseZDepth) - 0.0085
        bannerBottomNode.position.y = Float(-beetleImage!.size.height * 0.575 * scaleFactor)
        bannerBottomNode.scale.x = 0.0
        bannerBottomNode.opacity = 0
        rootNode.addChildNode(bannerBottomNode)
        bannerBottomNode.runAction(.sequence([
            .wait(duration: 1.9),
            .group([
                .fadeOpacity(to: 1.0, duration: 0.1),
                getScaler(d: 0.6)
                ])
            ])
        )
        
        sourceImage = UIImage(named: "Jewel_Left")
        let jewelLeftPlane = SCNPlane(width: sourceImage!.size.width * scaleFactor, height: sourceImage!.size.height * scaleFactor)
        let jewelLeftNode = SCNNode(geometry: jewelLeftPlane)
        jewelLeftNode.geometry?.firstMaterial?.diffuse.contents = sourceImage
        jewelLeftNode.position.z += 0.0125
        jewelLeftNode.position.x = Float(-beetleImage!.size.width * 0.6 * scaleFactor)
        jewelLeftNode.position.y = Float(beetleImage!.size.height * 0.3 * scaleFactor)
        jewelLeftNode.scale.x = 0.5
        jewelLeftNode.scale.y = 0.5
        jewelLeftNode.opacity = 0
        rootNode.addChildNode(jewelLeftNode)
        jewelLeftNode.runAction(.sequence([
            .wait(duration: 1.5),
            .group([
                .fadeOpacity(to: 1.0, duration: 0.25),
                getScaler(d: 0.25)
                ]),
            .repeatForever(.sequence([
                getMover(x: CGFloat(-beetleImage!.size.width * 0.6 * scaleFactor), y: CGFloat(beetleImage!.size.height * 0.3 * scaleFactor), z: 0.018, d: 2.5),
                getMover(x: CGFloat(-beetleImage!.size.width * 0.6 * scaleFactor), y: CGFloat(beetleImage!.size.height * 0.3 * scaleFactor), z: 0.008, d: 1.5)
                ]))
            ])
        )
        
        sourceImage = UIImage(named: "Jewel_Right")
        let jewelRightPlane = SCNPlane(width: sourceImage!.size.width * scaleFactor, height: sourceImage!.size.height * scaleFactor)
        let jewelRightNode = SCNNode(geometry: jewelRightPlane)
        jewelRightNode.geometry?.firstMaterial?.diffuse.contents = sourceImage
        jewelRightNode.position.z += 0.0125
        jewelRightNode.position.x = Float(beetleImage!.size.width * 0.6 * scaleFactor)
        jewelRightNode.position.y = Float(beetleImage!.size.height * 0.3 * scaleFactor)
        jewelRightNode.scale.x = 0.5
        jewelRightNode.scale.y = 0.5
        jewelRightNode.opacity = 0
        rootNode.addChildNode(jewelRightNode)
        jewelRightNode.runAction(.sequence([
            .wait(duration: 1.75),
            .group([
                .fadeOpacity(to: 1.0, duration: 0.25),
                getScaler(d: 0.25)
                ]),
            .repeatForever(.sequence([
                .wait(duration: 0.2),
                getMover(x: CGFloat(beetleImage!.size.width * 0.6 * scaleFactor), y: CGFloat(beetleImage!.size.height * 0.3 * scaleFactor), z: 0.018, d: 2.5),
                getMover(x: CGFloat(beetleImage!.size.width * 0.6 * scaleFactor), y: CGFloat(beetleImage!.size.height * 0.3 * scaleFactor), z: 0.008, d: 1.5)
                ]))
            ])
        )
        
        sourceImage = UIImage(named: "Jewel_Middle")
        let jewelMiddlePlane = SCNPlane(width: sourceImage!.size.width * scaleFactor, height: sourceImage!.size.height * scaleFactor)
        let jewelMiddleNode = SCNNode(geometry: jewelMiddlePlane)
        jewelMiddleNode.geometry?.firstMaterial?.diffuse.contents = sourceImage
        jewelMiddleNode.position.z += 0.0125
        jewelMiddleNode.position.y = Float(-beetleImage!.size.height * 0.5 * scaleFactor)
        jewelMiddleNode.scale.x = 0.5
        jewelMiddleNode.scale.y = 0.5
        jewelMiddleNode.opacity = 0
        rootNode.addChildNode(jewelMiddleNode)
        jewelMiddleNode.runAction(.sequence([
            .wait(duration: 2),
            .group([
                .fadeOpacity(to: 1.0, duration: 0.25),
                getScaler(d: 0.25)
                ]),
            .repeatForever(.sequence([
                .wait(duration: 0.35),
                getMover(x: 0, y: CGFloat(jewelMiddleNode.position.y), z: 0.018, d: 2.5),
                getMover(x: 0, y: CGFloat(jewelMiddleNode.position.y), z: 0.008, d: 1.5)
                ]))
            ])
        )
        
        sourceImage = UIImage(named: "Sun")
        let sunPlane = SCNPlane(width: sourceImage!.size.width * scaleFactor, height: sourceImage!.size.height * scaleFactor)
        let sunNode = SCNNode(geometry: sunPlane)
        sunNode.geometry?.firstMaterial?.diffuse.contents = sourceImage
        sunNode.geometry?.firstMaterial?.isDoubleSided = true
        sunNode.position.z += Float(baseZDepth) - 0.005
        
        sunNode.opacity = 0
        rootNode.addChildNode(sunNode)
        sunNode.runAction(.sequence([
            .wait(duration: 4.1),
            .group([.fadeOpacity(to: 1.0, duration: 0.5),
                    getMover(x: -beetleImage!.size.width * 0.7 * scaleFactor, y: -beetleImage!.size.height * 0.1 * scaleFactor, z: 0.02, d: 0.5)]),
            .repeatForever(.sequence([
                .wait(duration: 5.35),
                getSpinner(degrees: 180, d: 1.6),
                .wait(duration: 6.35),
                getSpinner(degrees: 0, d: 1.6)
                ]))
            ])
        )
        
        sourceImage = UIImage(named: "Moon")
        let moonPlane = SCNPlane(width: sourceImage!.size.width * scaleFactor, height: sourceImage!.size.height * scaleFactor)
        let moonNode = SCNNode(geometry: moonPlane)
        moonNode.geometry?.firstMaterial?.diffuse.contents = sourceImage
        moonNode.geometry?.firstMaterial?.isDoubleSided = true
        moonNode.position.z += Float(baseZDepth) - 0.005
        
        moonNode.opacity = 0
        rootNode.addChildNode(moonNode)
        moonNode.runAction(.sequence([
            .wait(duration: 4.5),
            .group([.fadeOpacity(to: 1.0, duration: 0.5),
                    getMover(x: beetleImage!.size.width * 0.7 * scaleFactor, y: -beetleImage!.size.height * 0.1 * scaleFactor, z: 0.02, d: 0.5)]),
            .repeatForever(.sequence([
                .wait(duration: 4.35),
                getSpinner(degrees: -180, d: 1.6),
                .wait(duration: 7.35),
                getSpinner(degrees: 0, d: 1.6)
                ]))
            ])
        )
        
        sourceImage = UIImage(named: "Skull_Left")
        let skullLeftPlane = SCNPlane(width: sourceImage!.size.width * scaleFactor, height: sourceImage!.size.height * scaleFactor)
        let skullLeftNode = SCNNode(geometry: skullLeftPlane)
        skullLeftNode.geometry?.firstMaterial?.diffuse.contents = sourceImage
        skullLeftNode.position.z += Float(baseZDepth) + 0.005
        skullLeftNode.position.x += Float(beetleImage!.size.width * 0.45 * scaleFactor)
        skullLeftNode.position.y += Float(-beetleImage!.size.height * 0.68 * scaleFactor)
        skullLeftNode.scale.x = 0.5
        skullLeftNode.scale.y = 0.5
        skullLeftNode.opacity = 0
        rootNode.addChildNode(skullLeftNode)
        skullLeftNode.runAction(.sequence([
            .wait(duration: 3.1),
            .group([
                .fadeOpacity(to: 1.0, duration: 0.25),
                getScaler(d: 0.5)
                ])
            ])
        )
        
        sourceImage = UIImage(named: "Skull_Left_Blink")
        let skullLeftBlinkPlane = SCNPlane(width: sourceImage!.size.width * scaleFactor, height: sourceImage!.size.height * scaleFactor)
        let skullLeftBlinkNode = SCNNode(geometry: skullLeftBlinkPlane)
        skullLeftBlinkNode.geometry?.firstMaterial?.diffuse.contents = sourceImage
        skullLeftBlinkNode.position.z += Float(baseZDepth) + 0.0051
        skullLeftBlinkNode.position.x += Float(beetleImage!.size.width * 0.45 * scaleFactor)
        skullLeftBlinkNode.position.y += Float(-beetleImage!.size.height * 0.68 * scaleFactor)
        skullLeftBlinkNode.opacity = 0
        rootNode.addChildNode(skullLeftBlinkNode)
        skullLeftBlinkNode.runAction(.sequence([
            .wait(duration: 4),
            .repeatForever(.sequence([
                .wait(duration: 3),
                .fadeOpacity(to: 1.0, duration: 0),
                .wait(duration: 0.1),
                .fadeOpacity(to: 0, duration: 0),
                .wait(duration: 0.3),
                .fadeOpacity(to: 1.0, duration: 0),
                .wait(duration: 0.1),
                .fadeOpacity(to: 0, duration: 0),
                .wait(duration: 2.5),
                ]))
            ]))
        
        sourceImage = UIImage(named: "Skull_Right")
        let skullRightPlane = SCNPlane(width: sourceImage!.size.width * scaleFactor, height: sourceImage!.size.height * scaleFactor)
        let skullRightNode = SCNNode(geometry: skullRightPlane)
        skullRightNode.geometry?.firstMaterial?.diffuse.contents = sourceImage
        skullRightNode.position.z += Float(baseZDepth) + 0.005
        skullRightNode.position.x += Float(-beetleImage!.size.width * 0.45 * scaleFactor)
        skullRightNode.position.y += Float(-beetleImage!.size.height * 0.68 * scaleFactor)
        skullRightNode.scale.x = 0.5
        skullRightNode.scale.y = 0.5
        skullRightNode.opacity = 0
        rootNode.addChildNode(skullRightNode)
        skullRightNode.runAction(.sequence([
            .wait(duration: 3.3),
            .group([
                .fadeOpacity(to: 1.0, duration: 0.25),
                getScaler(d: 0.5)
                ])
            ])
        )
        
        sourceImage = UIImage(named: "Skull_Right_Blink")
        let skullRightBlinkPlane = SCNPlane(width: sourceImage!.size.width * scaleFactor, height: sourceImage!.size.height * scaleFactor)
        let skullRightBlinkNode = SCNNode(geometry: skullRightBlinkPlane)
        skullRightBlinkNode.geometry?.firstMaterial?.diffuse.contents = sourceImage
        skullRightBlinkNode.position.z += Float(baseZDepth) + 0.0051
        skullRightBlinkNode.position.x += Float(-beetleImage!.size.width * 0.45 * scaleFactor)
        skullRightBlinkNode.position.y += Float(-beetleImage!.size.height * 0.68 * scaleFactor)
        skullRightBlinkNode.opacity = 0
        rootNode.addChildNode(skullRightBlinkNode)
        skullRightBlinkNode.runAction(.sequence([
            .wait(duration: 5),
            .repeatForever(.sequence([
                .wait(duration: 4),
                .fadeOpacity(to: 1.0, duration: 0),
                .wait(duration: 2),
                .fadeOpacity(to: 0, duration: 0),
                .wait(duration: 3),
                ]))
            ]))
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        // Delegate rendering tasks to our `updateQueue` thread to keep things thread-safe!
        updateQueue.async {
            let physicalWidth = imageAnchor.referenceImage.physicalSize.width
            let physicalHeight = imageAnchor.referenceImage.physicalSize.height
            
            // Create a plane geometry to visualize the initial position of the detected image
            let mainPlane = SCNPlane(width: physicalWidth, height: physicalHeight)
            
            // This bit is important. It helps us create occlusion so virtual things stay hidden behind the detected image
            mainPlane.firstMaterial?.colorBufferWriteMask = .alpha
            
            // Create a SceneKit root node with the plane geometry to attach to the scene graph
            // This node will hold the virtual UI in place
            let mainNode = SCNNode(geometry: mainPlane)
            mainNode.eulerAngles.x = -.pi / 2
            mainNode.renderingOrder = -1
            mainNode.opacity = 1
            
            // Add the plane visualization to the scene
            node.addChildNode(mainNode)

            self.releaseTheBeetle(on: mainNode, xOffset: physicalWidth)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
