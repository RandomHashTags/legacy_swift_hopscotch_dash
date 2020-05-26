//
//  HopscotchSquare.swift
//  Hopscotch Dash
//
//  Created by Evan Anderson on 5/25/20.
//  Copyright © 2020 RandomHashTags. All rights reserved.
//

import Foundation
import SpriteKit

class HopscotchSquare: NSObject, Randomable {
    private var squaresInRow:Int!, row:Int!, number:Int!
    private var shape:HopscotchShape!
    
    private var shapeNode:SKShapeNode!, label: SKLabelNode!
    private var moving:Bool!
    
    init(squaresInRow: Int, row: Int, number: Int, shape: HopscotchShape) {
        super.init()
        self.squaresInRow = squaresInRow
        self.row = row
        self.number = number
        self.shape = shape
        moving = false
        
        label = SKLabelNode(text: number.description)
        label.alpha = 1.00
        label.name = "squareLabel"
        label.fontSize = 45
        label.fontName = "Chalkduster"
        label.fontColor = .black
        label.zPosition = ZPositions.HOPSCOTCH_SQUARE_LABEL
        
        shapeNode = getShape(shape)
    }
    
    public func getRow() -> Int {
        return row
    }
    public func getShapeNode() -> SKShapeNode {
        return shapeNode
    }
    public func getShape() -> HopscotchShape {
        return shape
    }
    public func getLabelNode() -> SKLabelNode {
        return label
    }
    
    public func tapped() {
        let desc:String = shape.debugDescription, isDouble = desc.contains("DOUBLE"), isTriple = desc.contains("TRIPLE")
        if !isDouble && !isTriple {
            return
        } else if isDouble {
            shape = HopscotchShape.NORMAL
        } else if isTriple {
            shape = HopscotchShape.DOUBLE
        } else {
            return
        }
        let prevshape:SKShapeNode! = shapeNode.copy() as? SKShapeNode
        shapeNode.removeAllActions()
        shapeNode.removeAllChildren()
        shapeNode.removeFromParent()
        GAME_SCENE.removeChildren(in: [shapeNode])
        shapeNode = isDouble ? getNormalShape(moving: false) : getDoubleShape(moving: false)
        shapeNode.name = prevshape.name
        shapeNode.fillColor = prevshape.fillColor
        shapeNode.strokeColor = prevshape.strokeColor
        shapeNode.lineWidth = prevshape.lineWidth
        shapeNode.position = prevshape.position
        shapeNode.alpha = prevshape.alpha
        shapeNode.zPosition = prevshape.zPosition
        shapeNode.removeAllActions()
        label.removeAllActions()
        GAME_SCENE.addChild(shapeNode)
    }
    public static func valueOf(_ scene: SKScene, _ touch: UITouch) -> HopscotchSquare? {
        let touched = scene.nodes(at: touch.location(in: scene))
        for node in touched {
            if node is SKShapeNode {
                for square in SQUARES {
                    if square.shapeNode.isEqual(to: node) {
                        return square
                    }
                }
            }
        }
        return nil
    }
}

extension HopscotchSquare {
    public func updateShapeNode() {
        if moving {
            startMoving()
        }
    }
    private func getShape(_ type: HopscotchShape!) -> SKShapeNode! {
        switch type {
        case .NORMAL: return getNormalShape(moving: false)
        case .DOUBLE: return getDoubleShape(moving: false)
        case .TRIPLE: return getTripleShape(moving: false)
        case .WEIGHTED_NORMAL: return getWeightedShape()
        case .WEIGHTED_HEAVY: return getHeavyWeightedShape()
        case .MOVING_NORMAL: return getNormalShape(moving: true)
        case .MOVING_DOUBLE: return getDoubleShape(moving: true)
        case .MOVING_TRIPLE: return getTripleShape(moving: true)
        default: return nil
        }
    }
    private func getNormalShape(moving: Bool) -> SKShapeNode {
        let size:CGSize = CGSize(width: 115, height: 115)
        let shape:SKShapeNode = SKShapeNode(rectOf: size, cornerRadius: 20)
        shape.physicsBody = SKPhysicsBody(rectangleOf: size)
        setValues(shape)
        self.moving = moving
        return shape
    }
    private func getDoubleShape(moving: Bool) -> SKShapeNode {
        let radius:CGFloat = 115/2
        let shape:SKShapeNode = SKShapeNode(circleOfRadius: radius)
        shape.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        setValues(shape)
        self.moving = moving
        return shape
    }
    private func getTripleShape(moving: Bool) -> SKShapeNode {
        let radius:CGFloat = 115/2/1.5
        let shape:SKShapeNode = SKShapeNode(circleOfRadius: radius)
        shape.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        setValues(shape)
        self.moving = moving
        return shape
    }
    private func getWeightedShape() -> SKShapeNode {
        let size:CGSize = CGSize(width: 115, height: 115)
        let shape:SKShapeNode = SKShapeNode(rectOf: size)
        shape.physicsBody = SKPhysicsBody(rectangleOf: size)
        setValues(shape)
        shape.lineWidth = 7
        setRotation(shape, angle: 45)
        return shape
    }
    private func getHeavyWeightedShape() -> SKShapeNode {
        let size:CGSize = CGSize(width: 115, height: 115)
        let shape:SKShapeNode = SKShapeNode(rectOf: size, cornerRadius: 30)
        shape.physicsBody = SKPhysicsBody(rectangleOf: size)
        setValues(shape)
        shape.lineWidth = 9
        setRotation(shape, angle: -45)
        return shape
    }
    
    private func startMoving() {
        let offset:CGFloat = squaresInRow == 1 && Bool.random() ? CGFloat(getRandomNumber(min: 20, max: 60)) : 0
        startMoving(shapeNode, offset)
        startMoving(label, offset)
    }
    private func startMoving(_ node: SKNode, _ offset: CGFloat) {
        let position:CGPoint = node.position
        let run:SKAction = SKAction.move(to: CGPoint(x: position.x-30, y: position.y), duration: 0.5)
        node.run(run)
        let right:SKAction = SKAction.move(to: CGPoint(x: position.x+60+offset, y: position.y), duration: 0.50)
        let left:SKAction = SKAction.move(to: CGPoint(x: position.x-60-offset, y: position.y), duration: 0.50)
        let sequence:SKAction = SKAction.sequence([right, left])
        node.run(SKAction.repeatForever(sequence))
    }
    private func setRotation(_ shape: SKShapeNode, angle: CGFloat) {
        let waitAction:SKAction = SKAction.wait(forDuration: 0.50)
        let action:SKAction = SKAction.run {
            shape.run(SKAction.rotate(byAngle: angle, duration: 0.50))
        }
        let sequence:SKAction = SKAction.sequence([waitAction, action])
        shape.run(SKAction.repeatForever(sequence))
    }
    private func setValues(_ shape: SKShapeNode) {
        shape.zPosition = ZPositions.HOPSCOTCH_SQUARE
        shape.name = "square"
        shape.fillColor = getRandomUIColor()
        shape.strokeColor = .black
        shape.alpha = 1.00
        shape.lineWidth = 5
        shape.physicsBody!.isDynamic = false
        shape.physicsBody!.affectedByGravity = false
    }
}
