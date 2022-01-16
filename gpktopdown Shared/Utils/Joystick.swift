//
//  Joystick.swift
//  gpktopdown
//
//  Created by Willie Liwa Johnson on 1/16/22.
//

import SpriteKit

//MARK: StickData
public struct StickData: CustomStringConvertible {
    var vector = CGVector.zero,
    angular = CGFloat(0),
    centered = false
    
    mutating func reset() {
        vector = CGVector.zero
        angular = 0
        centered = true
    }
    
    public var description: String {
        return "StickData(velocity: \(vector), angular: \(angular))"
    }
}

//MARK: - StickComponent
open class StickComponent: SKSpriteNode {
    private var kvoContext = UInt8(1)
    var borderWidth = CGFloat(0) {
        didSet {
            redrawTexture()
        }
    }
    
    var borderColor = UIColor.black {
        didSet {
            redrawTexture()
        }
    }
    
    var image: UIImage? {
        didSet {
            redrawTexture()
        }
    }
    
    var diameter: CGFloat {
        get {
            return max(size.width, size.height)
        }
        
        set(newSize) {
            size = CGSize(width: newSize, height: newSize)
        }
    }
    
    var radius: CGFloat {
        get {
            return diameter * 0.5
        }
        
        set(newRadius) {
            diameter = newRadius * 2
        }
    }
    
    init(diameter: CGFloat, color: UIColor? = nil, image: UIImage? = nil) {
        super.init(texture: nil, color: color ?? UIColor.black, size: CGSize(width: diameter, height: diameter))
        addObserver(self, forKeyPath: "color", options: NSKeyValueObservingOptions.old, context: &kvoContext)
        self.diameter = diameter
        self.image = image
        redrawTexture()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserver(self, forKeyPath: "color")
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        redrawTexture()
    }
    
    private func redrawTexture() {
        
        guard diameter > 0 else {
            print("Diameter should be more than zero")
            texture = nil
            return
        }
        
        let scale = UIScreen.main.scale
        let needSize = CGSize(width: self.diameter, height: self.diameter)
        UIGraphicsBeginImageContextWithOptions(needSize, false, scale)
        let rectPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: needSize))
        rectPath.addClip()
        
        if let img = image {
            img.draw(in: CGRect(origin: CGPoint.zero, size: needSize), blendMode: .normal, alpha: 1)
        } else {
            color.set()
            rectPath.fill()
        }
        
        let needImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        texture = SKTexture(image: needImage)
    }
}

//MARK: - StickSubstrate
open class StickSubstrate: StickComponent {}

//MARK: - Stick
open class Stick: StickComponent {}

//MARK: - Joystick
open class Joystick: SKNode {
    var onMove: ((StickData) -> ())?
    var onStart: (() -> Void)?
    var onEnd: (() -> Void)?
    var substrate: StickSubstrate!
    var stick: Stick!
    private var moving = false
    private(set) var data = StickData()
    
    var centered: Bool {
        data.centered
    }
    
    var disabled: Bool {
        get {
            return !isUserInteractionEnabled
        }
        
        set(isDisabled) {
            isUserInteractionEnabled = !isDisabled
            
            if isDisabled {
                resetStick()
            }
        }
    }
    
    var diameter: CGFloat {
        get {
            return substrate.diameter
        }
        
        set(newDiameter) {
            stick.diameter += newDiameter - diameter
            substrate.diameter = newDiameter
        }
    }
    
    var colors: (substrate: UIColor, stick: UIColor) {
        get {
            return (substrate: substrate.color, stick: stick.color)
        }
        
        set(newColors) {
            substrate.color = newColors.substrate
            stick.color = newColors.stick
        }
    }
    
    
    var images: (substrate: UIImage?, stick: UIImage?)? {
        get {
            return (substrate: substrate.image, stick: stick.image)
        }
        
        set(newImages) {
            substrate.image = newImages?.substrate
            stick.image = newImages?.stick
        }
    }
    
    var radius: CGFloat {
        get {
            return diameter * 0.5
        }
        
        set(newRadius) {
            diameter = newRadius * 2
        }
    }
    
    init(substrate: StickSubstrate, stick: Stick) {
        super.init()
        self.substrate = substrate
        substrate.zPosition = 0
        addChild(substrate)
        self.stick = stick
        stick.zPosition = substrate.zPosition + 1
        addChild(stick)
        disabled = false
        let velocityLoop = CADisplayLink(target: self, selector: #selector(listen))
        velocityLoop.add(to: .current, forMode: .common)
    }
    
    convenience init(diameters: (substrate: CGFloat, stick: CGFloat?), colors: (substrate: UIColor , stick: UIColor) = (substrate: .black , stick: .white) , images: (substrate: UIImage?, stick: UIImage?)? = nil) {
        
        let stickDiameter = diameters.stick ?? diameters.substrate * 0.6
        let substrate = StickSubstrate(diameter: diameters.substrate, color: colors.substrate, image: images?.substrate)
        let stick = Stick(diameter: stickDiameter, color: colors.stick, image: images?.stick)
        
        self.init(substrate: substrate, stick: stick)
        
        self.colors = colors
        self.images = images
    }
    
    convenience init(diameter: CGFloat, colors: (substrate: UIColor , stick: UIColor) = (substrate: .black , stick: .white), images: (substrate: UIImage?, stick: UIImage?)? = nil) {
        self.init(diameters: (substrate: diameter, stick: nil), colors: colors, images: images)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func listen() {
        
        if moving {
            onMove?(data)
        }
    }
    
    //MARK: - Overrides
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first, stick == atPoint(touch.location(in: self)) {
            moving = true
            onStart?()
        }
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            
            guard moving else {
                return
            }
            
            let maxDistantion = substrate.radius,
                
            realDistantion = sqrt(pow(location.x, 2) + pow(location.y, 2)),
            needPosition = realDistantion <= maxDistantion ? CGPoint(x: location.x, y: location.y) : CGPoint(x: location.x / realDistantion * maxDistantion, y: location.y / realDistantion * maxDistantion)
            stick.position = needPosition
            data = StickData(vector: CGVector(dx: needPosition.x, dy: needPosition.y), angular: -atan2(needPosition.x, needPosition.y))
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetStick()
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetStick()
    }
    
    open override var description: String {
        return "Joystick(data: \(data), position: \(position))"
    }
    
    private func resetStick() {
        moving = false
        let moveToCenter = SKAction.move(to: CGPoint.zero, duration: TimeInterval(0.1))
        moveToCenter.timingMode = .easeOut
        stick.run(moveToCenter)
        data.reset()
        onEnd?();
    }
}
