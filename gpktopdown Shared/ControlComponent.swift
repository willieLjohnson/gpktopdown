//
//  ControlComponent.swift
//  gpktopdown
//
//  Created by Willie Liwa Johnson on 1/6/22.
//

import UIKit

import SpriteKit
import GameplayKit

class ControlComponent: GKComponent {
    var cruiseControl: Bool = true
    var cruiseAmount: CGFloat = 0.5
    var previousDirection: CGVector = CGVector.zero
    
    func touch(_ node: SKNode, location: CGPoint, joystick: AnalogJoystick?) {
        guard let entity = entity else { return }
        guard let visualComponent = entity.component(ofType: VisualComponent.self) else { return }
        
        if node == visualComponent.sprite {
            if let attackComponent = entity.component(ofType: AttackComponent.self) {
                attackComponent.attack()
            }
        }
    }
    
    func handleJoystick(_ joystick: AnalogJoystick) {
        guard let entity = entity else { return }
        guard let visualComponent = entity.component(ofType: VisualComponent.self) else { return }
        
        joystick.beginHandler = {
            self.cruiseControl = false
        }
        
        joystick.stopHandler = {
            self.cruiseControl = true
        }
        
        joystick.trackingHandler = { data in
            visualComponent.accelerate(data.velocity)
            self.previousDirection = data.velocity
        }
        
        if cruiseControl {
            visualComponent.accelerate(previousDirection * cruiseAmount)
        }
    }
}
