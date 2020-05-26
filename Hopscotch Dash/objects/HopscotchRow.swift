//
//  HopscotchRow.swift
//  Hopscotch Dash
//
//  Created by Evan Anderson on 5/25/20.
//  Copyright © 2020 RandomHashTags. All rights reserved.
//

import Foundation
import SpriteKit

class HopscotchRow: NSObject {
    private var squares:[HopscotchSquare]!, number:Int
    init(_ row: Int) {
        self.number = row
    }
    
    public func getNumber() -> Int {
        return number
    }
    public func getSquares() -> [HopscotchSquare] {
        return squares
    }
    public func setSquares(_ squares: [HopscotchSquare]) {
        self.squares = squares
    }
    public func didHop() {
        let action:SKAction = SKAction.fadeAlpha(to: 0.00, duration: 5.00)
        for square in squares {
            let shape:SKShapeNode = square.getShapeNode(), label:SKLabelNode = square.getLabelNode()
            shape.removeAllActions()
            label.removeAllActions()
            shape.fillColor = shape.fillColor.withAlphaComponent(0.20)
            shape.run(action)
            label.run(action)
            
            if let index = SQUARES.firstIndex(of: square) {
                SQUARES.remove(at: index)
            }
        }
        ROWS.removeFirst()
        for square in ROWS.first!.squares {
            square.getShapeNode().fillColor = .white
        }
    }
}
