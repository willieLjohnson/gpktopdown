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
    var scene: MainScene!
    
    let agentsEditor = AgentsEditor(namedGoals: [])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Present the scene
        let skView = self.view as! SKView
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        
        scene = MainScene(size: skView.frame.size)
        skView.presentScene(scene)
        viewDidLayoutSubviews()
        
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

