//
//  PopoverViewController.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 22/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit

class PopoverViewController: UIViewController {
    
    override func viewDidLoad() {
        let backgroundImage = UIImage(named: "popover-background")
        let background = UIImageView(image: backgroundImage!)
        background.frame = self.view.frame
        background.alpha = 0.7
        
        let logoImage = UIImage(named: "logo")
        let logo = UIImageView(image: logoImage!)
        logo.alpha = 0.6
        logo.frame.size = CGSize(width: 82.1, height: 15.0)
        logo.frame.origin = CGPoint(x: 5.0, y: 5.0)
        background.addSubview(logo)
        
        view.addSubview(background)
        view.sendSubviewToBack(background)
    }
}
