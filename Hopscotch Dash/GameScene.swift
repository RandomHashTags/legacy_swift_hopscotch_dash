//
//  GameScene.swift
//  Hopscotch Dash
//
//  Created by Evan Anderson on 12/25/18.
//  Copyright © 2018 RandomHashTags. All rights reserved.
//

import UIKit
import SpriteKit

var SCREEN = UIScreen.main.bounds
var SCREEN_WIDTH:CGFloat = SCREEN.width
var SCREEN_HEIGHT:CGFloat = SCREEN.height
var ROWS:[HopscotchRow] = [HopscotchRow]()
var SQUARES:[HopscotchSquare] = [HopscotchSquare]()

var GAME_SCENE:GameScene!

func viewGameOver(_ view: SKView) {
    let scene:SKScene! = SKScene(fileNamed: "GameOver")
    scene.scaleMode = .aspectFill
    view.presentScene(scene, transition: SKTransition.fade(withDuration: 1.00))
}

class GameScene: SKScene, Randomable {
    private let baseInterval:Double = 0.5500, hasForceTouch = !UIDevice.modelName.contains("iPhone 5s")
    private var interval:Double = 0.5500, intervalTimer:Timer!
    private var cameraTimers = [Timer]()
    private var cameraNode:SKCameraNode!, MIN_Y:CGFloat!
    private var totalSquares:Int = 0, totalRows:Int = 0
    private var running:Bool = false, playing:Bool = false
    private var momentumedRow:HopscotchRow?
    
    override func didMove(to view: SKView) {
        GAME_SCENE = self
        
        MIN_Y = scene!.frame.minY
        
        momentumedRow = nil
        
        cameraNode = SKCameraNode()
        cameraNode.name = "camera"
        cameraNode.zPosition = ZPositions.CAMERA
        self.camera = cameraNode
        addChild(cameraNode)
        
        running = false
        startGame()
    }
    
    override func willMove(from view: SKView) {
        for node in children {
            node.removeAllActions()
            node.physicsBody = nil
            node.removeAllChildren()
            node.removeFromParent()
        }
        ROWS.removeAll()
        SQUARES.removeAll()
        removeAllActions()
        removeAllChildren()
        removeFromParent()
        momentumedRow = nil
        intervalTimer = nil
        stopCameraTimers()
        cameraNode = nil
        MIN_Y = nil
        scoreboard.ended()
    }
    
    public func startGame() {
        totalSquares = 0
        totalRows = 0
        scoreboard.start()
        stopCameraTimers()
        cameraNode.position = CGPoint(x: 0, y: 0)
        running = true
        playing = false
        
        interval = baseInterval
        momentumedRow = nil
        
        generateRow(1)
        let firstSquare:HopscotchSquare! = SQUARES.first!
        firstSquare.getShapeNode().fillColor = .white
        for _ in 1...6 {
            generateRow(getNormalGenerateAmount())
        }
        updateTargetCushion(true)
    }
    private func getNormalGenerateAmount() -> Int {
        return getRandomNumber(min: 1, max: 2)
    }
    private func stopCameraTimers() {
        for timer in cameraTimers {
            timer.invalidate()
        }
        cameraTimers.removeAll()
    }
    public func endGame() {
        intervalTimer.invalidate()
        running = false
        stopCameraTimers()
        scoreboard.ended()
        viewGameOver(self.view!)
    }
    private func generateRow(_ amountInRow: Int) {
        addRow(amountInRow)
    }
    private func getRandomType() -> HopscotchShape {
        let type:HopscotchShape!
        let random:Int = getRandomNumber(min: 1, max: 100)
        if Bool.random() && random <= 40+(hasForceTouch ? 0 : 40) {
            let randomBool:Bool = Bool.random()
            type = random <= 20+(hasForceTouch ? 0 : 20) ? randomBool ? HopscotchShape.TRIPLE : HopscotchShape.MOVING_TRIPLE : randomBool ? HopscotchShape.DOUBLE : HopscotchShape.MOVING_DOUBLE
        } else {
            type = random <= 30 ? hasForceTouch && random <= 20 ? random <= 10 ? HopscotchShape.WEIGHTED_HEAVY : HopscotchShape.WEIGHTED_NORMAL : HopscotchShape.MOVING_NORMAL : HopscotchShape.NORMAL
        }
        return type
    }
    private func addRow(_ squaresInRow: Int) {
        let starting:Int = squaresInRow == 1 ? 0 : -100, randomX = getRandomNumber(min: -30, max: 30)
        let bestscore:Int = data.getValue(dataValue: .BEST_SCORE)
        var x:Int = starting
        let hopscotchRow:HopscotchRow = HopscotchRow.init(totalRows)
        let last:HopscotchSquare? = SQUARES.last
        let y:Int = Int(last != nil ? last!.getShapeNode().position.y+140 : -100)
        var squares:[HopscotchSquare] = [HopscotchSquare]()
        
        let action:SKAction = SKAction.fadeAlpha(to: 1.00, duration: 1.50)
        for _ in 1...squaresInRow {
            let shape:HopscotchShape! = getRandomType(), position = CGPoint(x: x+randomX, y: y)
            
            let hopscotchSquare:HopscotchSquare = HopscotchSquare(squaresInRow: squaresInRow, row: totalRows, number: totalSquares+1, shape: shape)
            let shapeNode:SKShapeNode = hopscotchSquare.getShapeNode()
            shapeNode.position = position
            addChild(shapeNode)
            
            let label:SKLabelNode = hopscotchSquare.getLabelNode()
            label.position = CGPoint(x: position.x, y: position.y-label.fontSize/2)
            addChild(label)
            
            hopscotchSquare.updateShapeNode()
            if totalSquares == bestscore {
                shapeNode.strokeColor = .red
            }
            
            shapeNode.run(action)
            label.run(action)
            
            squares.append(hopscotchSquare)
            SQUARES.append(hopscotchSquare)
            totalSquares += 1
            x += 200
        }
        totalRows += 1
        hopscotchRow.setSquares(squares)
        ROWS.append(hopscotchRow)
    }
    private func MoveCamera() {
        if running {
            let timer:Timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false, block: { (_) in
                self.moveCamera(self.interval)
                self.generateRow(self.getNormalGenerateAmount())
                self.MoveCamera()
            })
            cameraTimers.append(timer)
        } else {
            stopCameraTimers()
            intervalTimer.invalidate()
        }
    }
    private func moveCamera(_ interval: Double) {
        moveCamera(interval, 125)
    }
    private func moveCamera(_ interval: Double, _ byY: CGFloat) {
        UIView.animate(withDuration: interval, animations: {
            let p = self.cameraNode.position
            let m = SKAction.move(to: CGPoint(x: p.x, y: p.y+byY), duration: interval)
            self.cameraNode.run(m)
        })
    }
    private func tryHop(_ touches: Set<UITouch>, _ forces: [CGFloat]) {
        if running {
            var touchedSquares:[UITouch:HopscotchSquare] = [UITouch:HopscotchSquare]()
            var touchArray:[HopscotchSquare:UITouch] = [HopscotchSquare:UITouch]()
            for touch in touches {
                let square:HopscotchSquare? = HopscotchSquare.valueOf(self, touch)
                if square != nil {
                    touchedSquares[touch] = square!
                    touchArray[square!] = touch
                }
            }
            var missed:Bool = true, addscore:Bool = true
            let row:HopscotchRow! = ROWS.first!, rowNumber:Int = row.getNumber()
            let touchCount:Int = touches.count, squareCount = row.getSquares().count
            if !touchedSquares.isEmpty {
                let touchedSquaresKeys = touchedSquares.keys
                let firstTouch:UITouch = touchedSquaresKeys.first!
                let firstTouchedSquare = touchedSquares[firstTouch]!
                let second = touchedSquares[touchedSquaresKeys.reversed().first!]!
                let firstShape:HopscotchShape! = firstTouchedSquare.getShape()
                let firstTouchForce:CGFloat = firstTouch.force
                
                if firstTouchedSquare.getRow() == rowNumber && (firstTouchedSquare == second || second.getRow() == rowNumber) {
                    if touchCount == squareCount {
                        let firstRequiredForce:CGFloat = getRequiredForce(firstShape)
                        if touchCount == 1 {
                            addscore = isNormal(firstShape) || firstRequiredForce > 0.00 && firstTouchForce >= firstRequiredForce
                            missed = !addscore
                            if requiresMTOT(firstShape) {
                                missed = false
                                firstTouchedSquare.tapped()
                            }
                        } else {
                            let st:HopscotchShape! = second.getShape()
                            let stf = touchArray[second]!.force
                            let srf = getRequiredForce(st)
                            let frmtot = requiresMTOT(firstShape)
                            let srmtot = requiresMTOT(st)
                            if frmtot && srmtot {
                                missed = false
                                addscore = false
                                firstTouchedSquare.tapped()
                                second.tapped()
                            } else {
                                let missedFirstForce:Bool = firstRequiredForce > 0.00 && firstTouchForce < firstRequiredForce, missedSecondForce:Bool = srf > 0.00 && stf < srf
                                missed = missedFirstForce || missedSecondForce || frmtot && !srmtot || srmtot && !frmtot
                                addscore = !missed
                            }
                        }
                    } else if touchCount < squareCount {
                        let FIRST = touchedSquares[touches.first!]!
                        if requiresMTOT(FIRST.getShape()) {
                            addscore = false
                            missed = false
                            FIRST.tapped()
                        } else {
                            addscore = false
                            missed = true
                        }
                    } else {
                        addscore = false
                    }
                    if addscore {
                        row.didHop()
                    }
                } else {
                    addscore = false
                }
            }
            tryStartTimer()
            scoreboard.didTap(missed: missed, addscore: addscore)
            updateTargetCushion(missed || scoreboard.getMomentum() % 5 == 0)
        }
    }
    private func isNormal(_ type: HopscotchShape!) -> Bool {
        return type == HopscotchShape.NORMAL || type == HopscotchShape.MOVING_NORMAL
    }
    private func isDouble(_ type: HopscotchShape!) -> Bool {
        return type == HopscotchShape.DOUBLE || type == HopscotchShape.MOVING_DOUBLE
    }
    private func isTriple(_ type: HopscotchShape!) -> Bool {
        return type == HopscotchShape.TRIPLE || type == HopscotchShape.MOVING_TRIPLE
    }
    private func requiresMTOT(_ type: HopscotchShape!) -> Bool {
        return isDouble(type) || isTriple(type)
    }
    private func requiresForce(_ type: HopscotchShape!) -> Bool {
        return type.debugDescription.contains("WEIGHTED")
    }
    private func getRequiredForce(_ type: HopscotchShape!) -> CGFloat {
        return type == HopscotchShape.WEIGHTED_NORMAL ? 0.03 : type == HopscotchShape.WEIGHTED_HEAVY ? 0.09 : 0.00
    }
    public func updateMissesLeft(_ increased: Bool) {
        if !increased {
            let anim:CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            anim.duration = 0.25
            anim.values = [-10, 10, -10, 10, 0]
            self.view!.layer.add(anim, forKey: "shake")
        }
    }
    private func updateTargetCushion(_ missed: Bool) {
        if missed && running {
            if momentumedRow != nil {
                for square in momentumedRow!.getSquares() {
                    square.getShapeNode().strokeColor = .black
                }
            }
            let momentum:Int = scoreboard.getMomentum()
            let m:Int = 5-momentum, t = m < 0 || momentum % 5 == 0 ? 4 : m, count:Int = ROWS.count
            if count < 5 {
                for _ in 0..<5-count {
                    generateRow(getNormalGenerateAmount())
                }
            }
            let targetRow:HopscotchRow = ROWS[t]
            momentumedRow = targetRow
            let squares:[HopscotchSquare]! = targetRow.getSquares()
            for square in squares {
                square.getShapeNode().strokeColor = .cyan
            }
        }
    }
    private func tryStartTimer() {
        if intervalTimer == nil {
            playing = true
            moveCamera(interval)
            MoveCamera()
            intervalTimer = Timer.scheduledTimer(withTimeInterval: 3.50, repeats: true, block: { (_) in
                self.interval -= 0.003
            })
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if running {
            var forces:[CGFloat] = [CGFloat]()
            for touch in touches {
                forces.append(touch.force)
            }
            tryHop(touches, forces)
        }
    }
    override func update(_ currentTime: TimeInterval) {
        if running && playing {
            let Y:CGFloat = cameraNode.position.y+MIN_Y
            let row:HopscotchRow? = ROWS.first
            if row != nil {
                let square:SKShapeNode! = row!.getSquares().first!.getShapeNode()
                if square.frame.maxY <= Y {
                    endGame()
                }
            }
            for node in children {
                if node.frame.maxY <= Y {
                    node.removeAllActions()
                    node.removeFromParent()
                }
            }
        }
    }
}
