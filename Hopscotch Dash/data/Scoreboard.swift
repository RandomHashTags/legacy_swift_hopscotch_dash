//
//  Scoreboard.swift
//  Hopscotch Dash
//
//  Created by Evan Anderson on 5/25/20.
//  Copyright © 2020 RandomHashTags. All rights reserved.
//

import Foundation
import UIKit

class Scoreboard {
    private var score:Int!, momentum:Int!
    private var missedFeedback:UIImpactFeedbackGenerator!, momentumFeedback:UIImpactFeedbackGenerator!
    
    init() {
        missedFeedback = UIImpactFeedbackGenerator(style: .heavy)
        missedFeedback.prepare()
        momentumFeedback = UIImpactFeedbackGenerator(style: .light)
        momentumFeedback.prepare()
    }
    
    public func start() {
        score = 0
        momentum = 0
    }
    public func ended() {
        data.playedGame(score: score)
    }
    
    public func didTap(missed: Bool, addscore: Bool) {
        if missed {
            momentum = 0
            missedFeedback.impactOccurred()
            GAME_SCENE.updateMissesLeft(false)
        } else if addscore {
            score += 1
            momentum += 1
            if momentum % 5 == 0 {
                momentumFeedback.impactOccurred()
                GAME_SCENE.updateMissesLeft(true)
            }
        }
    }
    
    public func getScore() -> Int {
        return score
    }
    public func getMomentum() -> Int {
        return momentum
    }
}
