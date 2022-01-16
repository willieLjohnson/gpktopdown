//
//  IntelligenceComponent.swift
//  gpktopdown
//
//  Created by Willie Liwa Johnson on 1/6/22.
//

import UIKit

import GameplayKit

class IntelligenceComponent: GKAgent2D, GKAgentDelegate {
    let name: String
    
    var waitingMoveTime: TimeInterval = 0
    var waitingAttackTime: TimeInterval = 0
    let random = GKRandomDistribution(lowestValue: -30, highestValue: 30)
    
    init(name: String, target: GKAgent, avoid: [GKAgent]) {
        self.name = name
        super.init()
        delegate = self
        behavior = MoveBehavior(targetSpeed: 2, seek: target, avoid: avoid)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        waitingMoveTime += seconds
        waitingAttackTime += seconds


        if waitingMoveTime > 1 {
            waitingMoveTime = 0
        }
        
        if waitingAttackTime > 3 {
            if let entity = entity {
                if let attackComponent = entity.component(ofType: AttackComponent.self) {
                    attackComponent.attack()
                }
            }
            waitingAttackTime = 0
        }
    }
   
    func agentWillUpdate(_ agent: GKAgent) {
        print("agentWillUpdate")
        guard let entity = self.entity,
              let visualComponenet = entity.component(ofType: VisualComponent.self) else { return }
        let spritePosition = visualComponenet.sprite.position
        position = SIMD2<Float>(x: Float(spritePosition.x), y: Float(spritePosition.y))
    }
    
    func agentDidUpdate(_ agent: GKAgent) {
        print("agentDidUpdate")

        guard let entity = self.entity,
              let visualComponenet = entity.component(ofType: VisualComponent.self) else { return }
        visualComponenet.sprite.position = CGPoint(x: CGFloat(position.x), y: CGFloat(position.y))
    }
    
    func setWeight(namedGoal: NamedGoal) {
        behavior?.setWeight(namedGoal.weight * namedGoal.weightMultiplier, for: namedGoal.goal)
    }
    
}

class MoveBehavior: GKBehavior {
  init(targetSpeed: Float, seek: GKAgent, avoid: [GKAgent]) {
    super.init()
    // 2
    if targetSpeed > 0 {
      // 3
      setWeight(0.1, for: GKGoal(toReachTargetSpeed: targetSpeed))
      // 4
      setWeight(0.5, for: GKGoal(toSeekAgent: seek))
      // 5
      setWeight(1.0, for: GKGoal(toAvoid: avoid, maxPredictionTime: 1.0))
    }
  }
}
