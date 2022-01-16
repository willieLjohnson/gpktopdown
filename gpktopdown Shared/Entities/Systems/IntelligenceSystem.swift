//
//  IntelligenceSystem.swift
//  gpktopdown
//
//  Created by Willie Liwa Johnson on 1/4/22.
//  Copyright © 2022 Willie Liwa Johnson. All rights reserved.
//

import Foundation
import GameplayKit

class IntelligenceSystem: GKComponentSystem<IntelligenceComponent> {
    // AGENTS?
    let wanderGoal = NamedGoal(name: "Wander",
                               goal: GKGoal(toWander: 25),
                               weight: 60)
    
    lazy var separateGoal: NamedGoal =
    {
        [unowned self] in
        NamedGoal(name: "Separate",
                  goal: GKGoal(toSeparateFrom: self.agents,
                               maxDistance: 10,
                               maxAngle: Float(2 * Double.pi)),
                  weight: 10)
        
    }()
    
    lazy var alignGoal: NamedGoal =
    {
        [unowned self] in
        NamedGoal(name: "Align",
                  goal: GKGoal(toAlignWith: self.agents,
                               maxDistance: 20,
                               maxAngle: Float(2 * Double.pi)),
                  weight: 25)
    }()
    
    lazy var cohesionGoal: NamedGoal =
    {
        [unowned self] in
        NamedGoal(name: "Cohesion",
                  goal: GKGoal(toCohereWith: self.agents,
                               maxDistance: 20,
                               maxAngle: Float(2 * Double.pi)),
                  weight: 50)
    }()
    
    lazy var namedGoals: [NamedGoal] =
    {
        [unowned self] in
        [self.wanderGoal, self.separateGoal, self.alignGoal, self.cohesionGoal]
    }()
    
    
    public var agents: [GKAgent2D] {
        getGKAgent2D()
    }
    
    private func getGKAgent2D() -> [GKAgent2D] {
        return self.components
    }
}
