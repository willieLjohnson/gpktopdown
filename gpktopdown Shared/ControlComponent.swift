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
        
        joystick.trackingHandler = { data in
            visualComponent.accelerate(data.velocity)
        }
    }
}
