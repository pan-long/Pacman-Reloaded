//
//  MenuController.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 21/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import UIKit
import Foundation

// Subclassed by all popover menus to add background and pacman logo.
class MenuController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        AudioManager.playMenuSound()
        
        let backgroundImage = UIImage(named: "popover-background")
        let background = UIImageView(image: backgroundImage!)
        background.frame = self.view.frame
        background.alpha = Constants.PopoverMenu.BackgroundAlpha
        
        let logoImage = UIImage(named: "logo")
        let logo = UIImageView(image: logoImage!)
        logo.alpha = Constants.PopoverMenu.LogoAlpha
        logo.frame.size = CGSize(width: Constants.PopoverMenu.LogoWidth,
            height: Constants.PopoverMenu.LogoHeight)
        logo.frame.origin = CGPoint(x: Constants.PopoverMenu.LogoOriginX,
            y: Constants.PopoverMenu.LogoOriginY)
        background.addSubview(logo)
        
        view.addSubview(background)
        view.sendSubviewToBack(background)
    }

    deinit {
        AudioManager.playMenuSound()
    }

}
