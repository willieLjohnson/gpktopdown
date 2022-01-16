//
//  ControlComponent.swift
//  gpktopdown
//
//  Created by Willie Liwa Johnson on 1/6/22.
//

import UIKit

import SpriteKit
import GameplayKit

class ControllerComponent: GKAgent2D, GKAgentDelegate {
    var moveStick: Joystick
    
    var cruiseControl: Bool = true
    var cruiseAmount: CGFloat = 0.5
    var previousDirection: CGVector = CGVector.zero
    
    init(_ moveStick: Joystick) {
        self.moveStick = moveStick
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func touch(_ node: SKNode, location: CGPoint, joystick: Joystick?) {
        guard let entity = entity else { return }
        guard let visualComponent = entity.component(ofType: VisualComponent.self) else { return }
        
        if node == visualComponent.sprite {
            if let attackComponent = entity.component(ofType: AttackComponent.self) {
                attackComponent.attack()
            }
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        handleJoysticks()
    }
    
    func handleJoysticks() {
        guard let entity = entity else { return }
        guard let visualComponent = entity.component(ofType: VisualComponent.self) else { return }
        
        moveStick.onStart = {
            self.cruiseControl = false
        }
        
        moveStick.onEnd = {
            self.cruiseControl = true
        }
        
        moveStick.onMove = { data in
            visualComponent.accelerate(data.vector)
            self.previousDirection = data.vector
        }
        
        if cruiseControl {
            visualComponent.accelerate(previousDirection * cruiseAmount)
        }
    }
}
