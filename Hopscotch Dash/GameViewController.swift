//
//  GameViewController.swift
//  Hopscotch Dash
//
//  Created by Evan Anderson on 12/25/18.
//  Copyright © 2018 RandomHashTags. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

var GAME_CONTROLLER: GameViewController!

class GameViewController: UIViewController, ConstraintsAPI {
    
    private var ad: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GAME_CONTROLLER = self
        if let view = self.view as! SKView? {
            if let scene = SKScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
            view.isMultipleTouchEnabled = true
        }
        /*
        if(d.loadAds) {
            loadAds()
        }*/
    }
    
    public func loadAds() {
        ad = GADBannerView(adSize: kGADAdSizeBanner)
        ad.adUnitID = AdUnitIds.AD_MOB_BOTTOM_CENTER
        ad.rootViewController = self
        ad.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(ad)
        view.addConstraints([
            getConstraint(item: ad!, .bottom, toItem: view),
            getConstraint(item: ad!, .centerX, toItem: view)
        ])
        ad.load(GADRequest())
    }
    public func removeAdsFromGame() {
        UIView.animate(withDuration: 2.00, animations: {
            self.ad.alpha = 0.00
        }) { (_) in
            self.ad.removeFromSuperview()
        }
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .portrait
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
