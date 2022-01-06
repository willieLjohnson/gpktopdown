//
//  Useful.swift
//  gpktopdown
//
//  Created by Willie Liwa Johnson on 1/6/22.
//

import Foundation
import SpriteKit
import CoreImage.CIFilterBuiltins

import UIKit

import CoreGraphics

// MARK: Clamping
extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
extension Strideable where Self.Stride: SignedInteger {
    func clamped(to limits: CountableClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

// MARK: Points and vectors
//extension CGPoint {
//  init(_ point: float2) {
//      self.init()
//      x = CGFloat(point.x)
//    y = CGFloat(point.y)
//  }
//}
//extension float2 {
//  init(_ point: CGPoint) {
//    self.init(x: Float(point.x), y: Float(point.y))
//  }
//}

// MARK: Interpolation
struct Useful {
    static let context = CIContext()
    static let filter = CIFilter.checkerboardGenerator()
    
    static func differenceBetween(_ node: SKNode, and: SKNode) -> CGPoint {
        let dx = and.position.x - node.position.x
        let dy = and.position.y - node.position.y
        return CGPoint(x: dx, y: dy)
    }
    
    static func generateCheckerboardImage(size: CGSize, color: UIColor = .white) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            
            let cellSize = size * (1/4)
            
            for row in 0 ... Int(cellSize.height) {
                for col in 0 ... Int(cellSize.width) {
                    if (row + col) % 2 == 0 {
                        let position = CGPoint(x: CGFloat(col), y: CGFloat(row))
                        let randomSize = cellSize * CGFloat.random(in: 1.1...1.5)
                        ctx.cgContext.setFillColor(color.withAlphaComponent(.random(in: 0.05...0.1)).cgColor)
                        ctx.cgContext.fill(CGRect(x: position.x * cellSize.width, y: position.y * cellSize.height, width: randomSize.width, height: randomSize.height))
                    }
                }
            }
        }
        return img
    }
}

// MARK: - COLOR
extension SKColor {
    static var random: SKColor {
        return SKColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}

// MARK: - CGSize


/**
 * Multiplies two CGSize values and returns the result as a new CGSize.
 */
public func * (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width * right.width, height: left.height * right.height)
}

/**
 * Multiplies a CGSize with another.
 */
public func *= (left: inout CGSize, right: CGSize) {
    left = left * right
}

/**
 * Multiplies the x and y fields of a CGSize with the same scalar value and
 * returns the result as a new CGSize.
 */
public func * (size: CGSize, scalar: CGFloat) -> CGSize {
    return CGSize(width: size.width * scalar, height: size.height * scalar)
}

/**
 * Multiplies the x and y fields of a CGSize with the same scalar value.
 */
public func *= (size: inout CGSize, scalar: CGFloat) {
    size = size * scalar
}


extension CGVector {
    /**
     * Creates a new CGVector given a CGPoint.
     */
    public init(point: CGPoint) {
        self.init(dx: point.x, dy: point.y)
    }
    
    /**
     * Given an angle in radians, creates a vector of length 1.0 and returns the
     * result as a new CGVector. An angle of 0 is assumed to point to the right.
     */
    public init(angle: CGFloat) {
        self.init(dx: cos(angle), dy: sin(angle))
    }
    
    /**
     * Adds (dx, dy) to the vector.
     */
    public mutating func offset(dx: CGFloat, dy: CGFloat) -> CGVector {
        self.dx += dx
        self.dy += dy
        return self
    }
    
    /**
     * Returns the length (magnitude) of the vector described by the CGVector.
     */
    public func length() -> CGFloat {
        return sqrt(dx*dx + dy*dy)
    }
    
    /**
     * Returns the squared length of the vector described by the CGVector.
     */
    public func lengthSquared() -> CGFloat {
        return dx*dx + dy*dy
    }
    
    /**
     * Normalizes the vector described by the CGVector to length 1.0 and returns
     * the result as a new CGVector.
     public  */
    func normalized() -> CGVector {
        let len = length()
        return len>0 ? self / len : CGVector.zero
    }
    
    /**
     * Normalizes the vector described by the CGVector to length 1.0.
     */
    public mutating func normalize() -> CGVector {
        self = normalized()
        return self
    }
    
    /**
     * Calculates the distance between two CGVectors. Pythagoras!
     */
    public func distanceTo(_ vector: CGVector) -> CGFloat {
        return (self - vector).length()
    }
    
    /**
     * Returns the angle in radians of the vector described by the CGVector.
     * The range of the angle is -π to π; an angle of 0 points to the right.
     */
    public var angle: CGFloat {
        return atan2(dy, dx)
    }
}

/**
 * Adds two CGVector values and returns the result as a new CGVector.
 */
public func + (left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx + right.dx, dy: left.dy + right.dy)
}

// MARK: CGPOINT

public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}


public func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}


public func *= (left: inout CGPoint, right: CGPoint) {
    left = left * right
}

public func * (vector: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: vector.x * scalar, y: vector.y * scalar)
}



/**
 * Increments a CGVector with the value of another.
 */
public func += (left: inout CGVector, right: CGVector) {
    left = left + right
}

/**
 * Subtracts two CGVector values and returns the result as a new CGVector.
 */
public func - (left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx - right.dx, dy: left.dy - right.dy)
}

/**
 * Decrements a CGVector with the value of another.
 */
public func -= (left: inout CGVector, right: CGVector) {
    left = left - right
}

/**
 * Multiplies two CGVector values and returns the result as a new CGVector.
 */
public func * (left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx * right.dx, dy: left.dy * right.dy)
}

/**
 * Multiplies a CGVector with another.
 */
public func *= (left: inout CGVector, right: CGVector) {
    left = left * right
}

/**
 * Multiplies the x and y fields of a CGVector with the same scalar value and
 * returns the result as a new CGVector.
 */
public func * (vector: CGVector, scalar: CGFloat) -> CGVector {
    return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
}

/**
 * Multiplies the x and y fields of a CGVector with the same scalar value.
 */
public func *= (vector: inout CGVector, scalar: CGFloat) {
    vector = vector * scalar
}


/**
 * Divides two CGVector values and returns the result as a new CGVector.
 */
public func / (left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx / right.dx, dy: left.dy / right.dy)
}

/**
 * Divides a CGVector by another.
 */
public func /= (left: inout CGVector, right: CGVector) {
    left = left / right
}

/**
 * Divides the dx and dy fields of a CGVector by the same scalar value and
 * returns the result as a new CGVector.
 */
public func / (vector: CGVector, scalar: CGFloat) -> CGVector {
    return CGVector(dx: vector.dx / scalar, dy: vector.dy / scalar)
}

/**
 * Divides the dx and dy fields of a CGVector by the same scalar value.
 */
public func /= (vector: inout CGVector, scalar: CGFloat) {
    vector = vector / scalar
}

/**
 * Performs a linear interpolation between two CGVector values.
 */
public func lerp(start: CGVector, end: CGVector, t: CGFloat) -> CGVector {
    return start + (end - start) * t
}
