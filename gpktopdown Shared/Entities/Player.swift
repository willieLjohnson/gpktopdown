//
//  Player.swift
//  gpktopdown
//
//  Created by Willie Liwa Johnson on 1/16/22.
//

import Foundation
import GameplayKit
import SpriteKit

// MARK: - DEFAULTS
extension Player {
    static let DEFAULT_SIZE = CGSize(width: 30.0, height: 30.0)
    static var DEFAULT_PHYSICSBODY: SKPhysicsBody {
        let physicsBody  = SKPhysicsBody(rectangleOf: Player.DEFAULT_SIZE)
        physicsBody.affectedByGravity = false
        physicsBody.linearDamping = World.FRICTION
        return physicsBody
    }
}

class Player: GKEntity {
    private var visualComponent: VisualComponent
    private var controllerComponent: ControllerComponent
    
    var sprite: SKSpriteNode {
        visualComponent.sprite
    }
    
    var physicsBody: SKPhysicsBody {
        sprite.physicsBody!
    }
    
    var position: CGPoint {
        sprite.position
    }
    
    lazy var comps: (visual: VisualComponent, controller: ControllerComponent) = { [unowned self] in
        return (visual: self.visualComponent, controller: self.controllerComponent)
    }()
    
    init(position: CGPoint, moveStick: Joystick) {
        visualComponent = VisualComponent(color: SKColor.cyan, size: Player.DEFAULT_SIZE)
        visualComponent.position = position
        visualComponent.sprite.physicsBody = Player.DEFAULT_PHYSICSBODY
        
        controllerComponent = ControllerComponent(moveStick)
        
        super.init()

        addComponent(visualComponent)
        addComponent(AttackComponent())
        addComponent(controllerComponent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
