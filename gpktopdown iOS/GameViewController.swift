//
//  GameViewController.swift
//  gpktopdown iOS
//
//  Created by Willie Liwa Johnson on 1/6/22.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    var scene: EntitiesScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Present the scene
        let skView = self.view as! SKView
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        scene = EntitiesScene(size: skView.frame.size)
        
        skView.presentScene(scene)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
