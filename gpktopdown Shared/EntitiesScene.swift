//
//  EntitiesScene.swift
//  gpktopdown
//
//  Created by Willie Liwa Johnson on 1/6/22.
//

import UIKit

import SpriteKit
import GameplayKit

struct World {
    static let FRICTION = 0.5
}

class EntitiesScene: BaseScene {
    var player: GKEntity!
    var enemies = [GKEntity]()
    var boss: GKEntity!
    
    var backgroundSize: CGSize = .zero
    var gridCount: CGFloat = 2
    var backgroundGridSize: CGSize {
        backgroundSize * gridCount
    }
    
    let intelligenceSystem = GKComponentSystem(componentClass: IntelligenceComponent.self)
    
    let movePlayerStick = AnalogJoystick(diameters: (135, 100))
    var playerControlComponent: ControlComponent {
        player.component(ofType: ControlComponent.self)!
    }
    var playerVisualComponent: VisualComponent {
        player.component(ofType: VisualComponent.self)!
    }
    
    
    func generateBackgroundImage(color: UIColor = .black.withAlphaComponent(0.1), result: @escaping (SKSpriteNode) -> Void) {
        let generatedImage = Useful.generateCheckerboardImage(size: self.backgroundSize, color: color)
        let background = SKSpriteNode(texture: SKTexture(image: generatedImage))
        background.name = "background"
        background.size = self.backgroundSize
        background.zPosition = -2000
        DispatchQueue.main.async {
            result(background)
        }
    }
    
    override func createSceneContents() {
        backgroundSize = CGSize(width: size.width, height: size.width)

        var count = 0
        DispatchQueue.global(qos: .userInteractive).async {
            for x in 0...1 {
                for y in 0...1 {
                    self.generateBackgroundImage(color: .black.withAlphaComponent(0.1 + CGFloat((x + y) / 4))) { generatedBackground in
                        let xPosition = CGFloat(x) * self.backgroundSize.width
                        let yPosition = CGFloat(y) * self.backgroundSize.height
                        generatedBackground.position = CGPoint(x: xPosition, y: yPosition)
                        self.addChild(generatedBackground)
                        count += 1
                        print(count)
                    }
                }
            }
        }
        
        
        //        background.size = frame.size
        //        background.position = CGPoint(x: frame.midX, y: frame.midY)
        //        addChild(background)
        
        createLabel("■ Player: Visual, Attack, Control", color: SKColor.cyan, order: 0)
        createLabel("■ Boss: Visual, Attack, Intelligence", color: SKColor.magenta, order: 2)
        createLabel("■ Enemy: Visual, Intelligence", color: SKColor.yellow, order: 1)
        
        movePlayerStick.position = CGPoint(x: -size.width / 2 + movePlayerStick.radius * 2, y: -size.height / 2 + movePlayerStick.radius * 2)
        movePlayerStick.stick.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
        movePlayerStick.substrate.color = #colorLiteral(red: 0.6722276476, green: 0.6722276476, blue: 0.6722276476, alpha: 0.3)
        
        let cam = SKCameraNode()
        cam.addChild(movePlayerStick)
        cam.zPosition = 2000
        self.camera = cam
        addChild(cam)
        
        createPlayer()
        createEnemies()
        createBoss()
    }
    
    
    func createPlayer() {
        player = GKEntity()
        let playerSize = CGSize(width: 30.0, height: 30.0)
        
        let visualComponent = VisualComponent(color: SKColor.cyan, size: playerSize)
        visualComponent.position = center
        
        let physicsBody  = SKPhysicsBody(rectangleOf: CGSize(width: 35.0, height: 35.0))
        physicsBody.affectedByGravity = false
        physicsBody.linearDamping = World.FRICTION
        visualComponent.sprite.physicsBody = physicsBody
        
        
        player.addComponent(visualComponent)
        addChild(visualComponent.sprite)
        
        let attackComponent = AttackComponent()
        player.addComponent(attackComponent)
        
        let controlComponent = ControlComponent()
        controlComponent.handleJoystick(movePlayerStick)
        player.addComponent(controlComponent)
    }
    
    func createEnemies() {
        for _ in 0..<20 {
            let enemy = GKEntity()
            enemies.append(enemy)
            
            let visualComponent = VisualComponent(color: SKColor.yellow, size: CGSize(width: 20.0, height: 20.0))
            visualComponent.position = randomPosition()
            enemy.addComponent(visualComponent)
            addChild(visualComponent.sprite)
            
            let intelligenceComponent = IntelligenceComponent()
            enemy.addComponent(intelligenceComponent)
            intelligenceSystem.addComponent(intelligenceComponent)
        }
    }
    
    func createBoss() {
        boss = GKEntity()
        
        let visualComponent = VisualComponent(color: SKColor.magenta, size: CGSize(width: 50.0, height: 50.0))
        visualComponent.position = randomPosition()
        boss.addComponent(visualComponent)
        addChild(visualComponent.sprite)
        
        let attackComponent = AttackComponent()
        boss.addComponent(attackComponent)
        
        let intelligenceComponent = IntelligenceComponent()
        boss.addComponent(intelligenceComponent)
        intelligenceSystem.addComponent(intelligenceComponent)
    }
    
    func randomPosition() -> CGPoint {
        let x = GKRandomDistribution(lowestValue: 50, highestValue: Int(frame.maxX) - 50).nextInt()
        let y = GKRandomDistribution(lowestValue: 50, highestValue: Int(frame.maxY) - 50).nextInt()
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        player.update(deltaTime: deltaTime)
        
        playerControlComponent.handleJoystick(movePlayerStick)
        intelligenceSystem.update(deltaTime: deltaTime)
        
        guard let playerPhysicsBody = playerVisualComponent.physicsBody else { return }
        guard let camera = self.camera else { return }
        
        // Move cam to player
        //        let duration = TimeInterval(0.4 * pow(0.9, abs(playerPhysicsBody.velocity.dx / 100) - 1) + 0.05)
        //        let xOffsetExpo = CGFloat(0.4 * pow(0.9, -abs(playerPhysicsBody.velocity.dx) / 100 - 1) - 0.04)
        //        let yOffsetExpo = CGFloat(0.2 * pow(0.9, -abs(playerPhysicsBody.velocity.dy) / 100 - 1) - 0.04)
        //        let scaleExpo = CGFloat(0.001 * pow(0.9, -abs(playerPhysicsBody.velocity.dx) / 100  - 1) + 3.16)
        //        let xOffset = xOffsetExpo.clamped(to: -1500...1500) * (playerPhysicsBody.velocity.dx > 0 ? 1 : -1)
        //        let yOffset = yOffsetExpo.clamped(to: -1500...1500) * (playerPhysicsBody.velocity.dy > 0 ? 1 : -1)
        //
        //        let scale = scaleExpo.clamped(to: 3...5.5)
        
        //        camera.setScale(scale)
        //CGPoint(x: playerVisualComponent.sprite.position.x + xOffset, y: playerVisualComponent.sprite.position.y + yOffset)
//        camera.run(SKAction.move(to: playerVisualComponent.sprite.position, duration: 0.005))
        
        let playerSprite = playerVisualComponent.sprite
        camera.position = playerSprite.position
        
        self.enumerateChildNodes(withName: "background", using: ({
            (node, error) in
            // 1
            //            node.position.x += playerPhysicsBody.velocity.dx * 0.01 + cos(currentTime)
            //            node.position.y += playerPhysicsBody.velocity.dy * 0.01 + sin(currentTime)
            

            let limitX = self.backgroundGridSize.width - self.size.width
            let limitY = self.backgroundGridSize.height - self.size.width
            
            var newPosition = node.position
            
            if playerPhysicsBody.velocity.dx > 0 && node.position.x < (playerSprite.position.x - limitX)  {
                newPosition.x += self.backgroundGridSize.width
            }
            if playerPhysicsBody.velocity.dy > 0 && node.position.y < (playerSprite.position.y - limitY)  {
                newPosition.y += self.backgroundGridSize.height
            }
            
            if playerPhysicsBody.velocity.dx < 0 && node.position.x > (playerSprite.position.x + limitX)  {
                newPosition.x -= self.backgroundGridSize.width
            }
            if playerPhysicsBody.velocity.dy < 0 && node.position.y > (playerSprite.position.y + limitY)  {
                newPosition.y -= self.backgroundGridSize.height
            }
            
            node.position = newPosition
            //
            //            if playerSprite.position.y > (node.position.y + self.backgroundSize.height * 0.25 * self.gridCount) {
            //                node.position.y += self.backgroundSize.height * self.gridCount
            //            }
            //
            //
            //            if playerPhysicsBody.velocity.dx < 0 || playerPhysicsBody.velocity.dy < 0 {
            //                if node.position.x > self.backgroundSize.width / 2 + self.playerVisualComponent.sprite.position.x {
            //                    node.position.x -= self.backgroundSize.width
            //                }
            //
            //                if node.position.y > self.backgroundSize.height / 2 + self.playerVisualComponent.sprite.position.y {
            //                    node.position.y -= self.backgroundSize.height
            //                }
            //            }
        }))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let node = atPoint(location)
    }
}
