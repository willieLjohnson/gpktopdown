//
//  VisualComponent.swift
//  gpktopdown
//
//  Created by Willie Liwa Johnson on 1/6/22.
//

import UIKit

import SpriteKit
import GameplayKit

class VisualComponent: GKComponent {
    let sprite: SKSpriteNode
    let speed: CGFloat = 4
    var acceleration: CGVector = .zero
    
    var isAccelerating: Bool {
        acceleration.length() > 1
    }
    
    var physicsBody: SKPhysicsBody? {
        sprite.physicsBody
    }
    
    var momentum: CGVector = .zero
    
    var isMoving: Bool {
        get {
            abs(sprite.physicsBody!.velocity.dx) > 0 || abs(sprite.physicsBody!.velocity.dy) > 0
        }
    }
    
    var spriteSize: CGSize {
        get {
            sprite.size
        }
    }

    var position = CGPoint.zero {
        didSet {
            sprite.position = position
        }
    }

    init(color: SKColor, size: CGSize) {
        sprite = SKSpriteNode(color: color, size: size)
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func moveTo(_ position: CGPoint) {
        let action = SKAction.move(to: position, duration: 0.3)
        sprite.run(action, completion: {
            self.position = position
        }) 
    }

    func moveBy(_ x: CGFloat, _ y: CGFloat) {
        let p = CGPoint(x: position.x + x, y: position.y + y)
        moveTo(p)
    }
    
    func accelerate(_ direction: CGVector) {
        guard let physicsBody = sprite.physicsBody else { return }
        acceleration = lerp(start: acceleration, end: direction * speed, t: 0.35 + (0.1 - (momentum.length() * 0.001)))
        physicsBody.applyForce(acceleration)
    }
    
    func updatePhysics() {
        guard let physicsBody = sprite.physicsBody else { return }

        if isAccelerating {
            acceleration = lerp(start: acceleration, end: .zero, t: 0.2)
            momentum = lerp(start: momentum, end: physicsBody.velocity, t: 0.01)
        } else {
            momentum = lerp(start: momentum, end: physicsBody.velocity, t: 0.1)
            acceleration = .zero
            
        }
    }
}
