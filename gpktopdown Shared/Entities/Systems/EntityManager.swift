//
//  EntityManager.swift
//  gpktopdown iOS
//
//  Created by Willie Liwa Johnson on 1/16/22.
//

import Foundation
import SpriteKit
import GameplayKit

class EntityManager {
    
    let scene: SKScene
    
    var entities = Set<GKEntity>()
    var entitiesToRemove = Set<GKEntity>()
    
    lazy var componentSystems: [GKComponentSystem] = {
        let intelligenceSystem = GKComponentSystem(componentClass: IntelligenceComponent.self)
        let controllerSystem = GKComponentSystem(componentClass: ControllerComponent.self)
        return [controllerSystem, intelligenceSystem]
    }()
    
    init(scene: SKScene) {
        self.scene = scene
    }
        
    func add(_ entity: GKEntity) {
        entities.insert(entity)
        
        if let sprite = entity.component(ofType: VisualComponent.self)?.sprite {
            scene.addChild(sprite)
        }
        
        for componentSystem in componentSystems {
            componentSystem.addComponent(foundIn: entity)
        }
    }
    
    func update(_ deltaTime: CFTimeInterval) {
        for componentSystem in componentSystems {
            componentSystem.update(deltaTime: deltaTime)
        }
        
        for entityToRemove in entitiesToRemove {
            for componentSystem in componentSystems {
                componentSystem.removeComponent(foundIn: entityToRemove)
            }
            entities.remove(entityToRemove)
        }
        entitiesToRemove.removeAll()
    }
    
    func remove(_ entity: GKEntity) {
        if let sprite = entity.component(ofType: VisualComponent.self)?.sprite {
            sprite.removeFromParent()
        }
        
        entitiesToRemove.insert(entity)
    }
}
