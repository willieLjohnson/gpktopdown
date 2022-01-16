//
//  MainScene.swift
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

class MainScene: Scene {
    var entityManager: EntityManager!
    var player: Player!
    
    var boss: GKEntity!
    var enemies = [GKEntity]()
    
    var backgroundSize: CGSize = .zero
    var gridCount: CGFloat = 2
    var backgroundGridSize: CGSize {
        backgroundSize * gridCount
    }
    
    let intelligenceSystem = IntelligenceSystem(componentClass: IntelligenceComponent.self)
    
    let movePlayerStick = Joystick(diameters: (135, 100))

    let obstacles = [GKCircleObstacle(radius: 100),
                     GKCircleObstacle(radius: 100),
                     GKCircleObstacle(radius: 100),
                     GKCircleObstacle(radius: 100)]
    
    var selectionMode = SelectionMode.None
    
    override func didMove(to view: SKView) {
        entityManager = EntityManager(scene: self)
        setupUI()
        createPlayer()
        createSceneContents()
    }
    
    override func createSceneContents() {
        createEnemies()
        createBoss()
        
        drawObstacles()
        
        obstacles[0].position = vector_float2(-200, -200)
        obstacles[1].position = vector_float2(-200, 200)
        obstacles[2].position = vector_float2(200, -200)
        obstacles[3].position = vector_float2(200, 200)
        
        drawObstacles()
    }
    

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        entityManager.update(deltaTime)
        
        guard let playerPhysicsBody = player.sprite.physicsBody else { return }
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
    
        camera.position = player.sprite.position
        
        self.enumerateChildNodes(withName: "background", using: ({
            (node, error) in
            // 1
            guard let node = node as? SKSpriteNode else { return }
            
            node.size.width += cos(currentTime)
            node.size.height += sin(currentTime)


            let limitX = self.backgroundGridSize.width - self.size.width
            let limitY = self.backgroundGridSize.height - self.size.width
            
            var newPosition = node.position
            
            if playerPhysicsBody.velocity.dx > 0 && node.position.x < (self.player.position.x - limitX)  {
                newPosition.x += self.backgroundGridSize.width
            }
            if playerPhysicsBody.velocity.dy > 0 && node.position.y < (self.player.position.y - limitY)  {
                newPosition.y += self.backgroundGridSize.height
            }
            
            if playerPhysicsBody.velocity.dx < 0 && node.position.x > (self.player.position.x + limitX)  {
                newPosition.x -= self.backgroundGridSize.width
            }
            if playerPhysicsBody.velocity.dy < 0 && node.position.y > (self.player.position.y + limitY)  {
                newPosition.y -= self.backgroundGridSize.height
            }
            
            node.position = newPosition
        }))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPosition = touches.first?.location(in: self) else {
            return
        }
        
        let adjustedTouchLocation = vector_float2(Float(touchPosition.x - frame.width / 2),
                                                  Float(touchPosition.y - frame.height / 2))
    
        
        for (index, obstacle) in obstacles.enumerated()
        {
            let distToObstacle = hypot(adjustedTouchLocation.x - obstacle.position.x,
                                       adjustedTouchLocation.y - obstacle.position.y)
            
            if distToObstacle < obstacle.radius
            {
                selectionMode = .Obstacle(index: index)
                return
            }
        }
        
        selectionMode = .None
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPosition = touches.first?.location(in: self) else
        {
            return
        }
        
        let adjustedTouchLocation = vector_float2(Float(touchPosition.x - frame.width / 2),
                                                  Float(touchPosition.y - frame.height / 2))
        
        switch selectionMode
        {
        case .None:
            return
//            drawSeekGoals()
        case .Obstacle(let idx):
            obstacles[idx].position = adjustedTouchLocation
            drawObstacles()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectionMode = .None
    }
}

// MARK: - Entitites scene methods
private extension MainScene {
    
//    func drawSeekGoals()
//    {
//
//        seekGoalsLayer.strokeColor = UIColor.blue.cgColor
//        seekGoalsLayer.fillColor = nil
//        seekGoalsLayer.lineWidth = 2
//
//        let bezierPath = UIBezierPath()
//
//        for seekTarget in targets
//        {
//            bezierPath.appendCircleOfRadius(radius: seekTarget.radius,
//                                            atPosition: seekTarget.position,
//                                            inFrame: frame)
//        }
//
//        seekGoalsLayer.path = bezierPath.cgPath
//    }
    
    func drawObstacles() {
        for obstacle in obstacles {
            let obstacleShape = SKShapeNode(circleOfRadius: CGFloat(obstacle.radius))
            obstacleShape.strokeColor = SKColor.red
            obstacleShape.position = CGPoint(x: CGFloat(obstacle.position.x), y: CGFloat(obstacle.position.y))
            addChild(obstacleShape)
        }
    }
    
    
    func generateBackgroundImage(color: UIColor = .black, result: @escaping (SKSpriteNode) -> Void) {
        let (generatedImage, _) = Useful.generateCheckerboardImage(size: self.backgroundSize, color: color)
        let background = SKSpriteNode(texture: SKTexture(image: generatedImage))
        background.name = "background"
        background.size = self.backgroundSize
        background.zPosition = -2000
        DispatchQueue.main.async {
            result(background)
        }
    }
    
    func generateBackgroundGrid() {
        backgroundSize = CGSize(width: size.width, height: size.width)

        DispatchQueue.global(qos: .userInteractive).async {
            for x in 0...1 {
                for y in 0...1 {
                    self.generateBackgroundImage() { generatedBackground in
                        let xPosition = CGFloat(x) * self.backgroundSize.width
                        let yPosition = CGFloat(y) * self.backgroundSize.height
                        generatedBackground.position = CGPoint(x: xPosition, y: yPosition)
                        self.addChild(generatedBackground)
                    }
                }
            }
        }
    }
    
    
    func setupUI() {
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
        
        generateBackgroundGrid()
    }
    

    
    func createPlayer() {
        player = Player(position: center, moveStick: movePlayerStick)
        entityManager.add(player)
    }
    
    func createEnemies() {
        for i in 0..<20 {
            let enemy = GKEntity()
            enemies.append(enemy)
            
            let visualComponent = VisualComponent(color: SKColor.yellow, size: CGSize(width: 20.0, height: 20.0))
            visualComponent.position = randomPosition()
            enemy.addComponent(visualComponent)
            
            let intelligenceComponent = IntelligenceComponent(name: "enemy-\(i)", target: player.comps.controller, avoid: intelligenceSystem.agents)
            enemy.addComponent(intelligenceComponent)
            intelligenceSystem.addComponent(intelligenceComponent)
            
            entityManager.add(enemy)
        }
    }
    
    func createBoss() {
        boss = GKEntity()
        
        let visualComponent = VisualComponent(color: SKColor.magenta, size: CGSize(width: 50.0, height: 50.0))
        visualComponent.position = randomPosition()
        boss.addComponent(visualComponent)
        
        let attackComponent = AttackComponent()
        boss.addComponent(attackComponent)
        
        let intelligenceComponent = IntelligenceComponent(name: "boss", target: player.comps.controller, avoid: intelligenceSystem.agents)
        boss.addComponent(intelligenceComponent)
        intelligenceSystem.addComponent(intelligenceComponent)
        
        entityManager.add(boss)
    }
    
    func randomPosition() -> CGPoint {
        let x = GKRandomDistribution(lowestValue: 50, highestValue: Int(frame.maxX) - 50).nextInt()
        let y = GKRandomDistribution(lowestValue: 50, highestValue: Int(frame.maxY) - 50).nextInt()
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}

enum SelectionMode {
    case None
    case Obstacle(index: Int)
}
