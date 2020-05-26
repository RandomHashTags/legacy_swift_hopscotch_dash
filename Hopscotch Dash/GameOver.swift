//
//  GameOver.swift
//  Hopscotch Dash
//
//  Created by Evan Anderson on 5/4/19.
//  Copyright © 2019 RandomHashTags. All rights reserved.
//

import SpriteKit

class GameOver: SKScene {
    
    private var restart:SKSpriteNode!
    
    override func didMove(to view: SKView) {
        let scoreLabel:SKLabelNode = SKLabelNode(text: scoreboard.getScore().description)
        scoreLabel.fontColor = .white
        scoreLabel.fontSize = 50
        scoreLabel.fontName = "ChalkboardSE-Bold"
        
        let SCORE:SKLabelNode! = scoreLabel.copy() as? SKLabelNode, BESTSCORE:SKLabelNode! = scoreLabel.copy() as? SKLabelNode
        let bestscore:SKLabelNode! = scoreLabel.copy() as? SKLabelNode, width:CGFloat = SCREEN_WIDTH/2
        SCORE.text = "SCORE"
        SCORE.fontSize = 70
        BESTSCORE.text = "BEST"
        BESTSCORE.fontSize = 70
        
        bestscore.text = data.getValue(dataValue: DataValue.BEST_SCORE).description
        
        SCORE.position = CGPoint(x: -width, y: 100)
        scoreLabel.position = CGPoint(x: -width, y: 0)
        BESTSCORE.position = CGPoint(x: width, y: 100)
        bestscore.position = CGPoint(x: width, y: 0)
        
        addChild(SCORE)
        addChild(scoreLabel)
        addChild(BESTSCORE)
        addChild(bestscore)
        
        restart = SKSpriteNode(imageNamed: "restart.png")
        restart.position = CGPoint(x: 0, y: -400)
        addChild(restart)
    }
    
    public func newBestScore() {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let tappedNodes:[SKNode] = nodes(at: touches.first!.location(in: self))
        if tappedNodes.contains(restart) {
            restartGame()
        }
    }
    
    private func restartGame() {
        let scene:SKScene! = SKScene(fileNamed: "GameScene")
        scene.scaleMode = .aspectFill
        self.view!.presentScene(scene, transition: SKTransition.crossFade(withDuration: 0.75))
    }
}
