//
//  GameBackgroundViewController.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 21/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit

class GameBackgroundViewController: UIViewController {
    
    override func viewDidLoad() {
        let backgroundImage = UIImage(named: "landing-page")
        let background = UIImageView(image: backgroundImage!)
        background.frame = self.view.frame
        view.addSubview(background)
        view.sendSubviewToBack(background)
    }
}