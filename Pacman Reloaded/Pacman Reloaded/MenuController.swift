//
//  MenuController.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 21/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import UIKit
import Foundation

class MenuController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        AudioManager.playMenuSound()
//        self.view.layer.borderColor = UIColor.redColor().CGColor
//        self.view.layer.borderWidth = CGFloat(3.0)
//        self.view.layer.cornerRadius = 5;
//        self.view.backgroundColor = UIColor.clearColor()
//        let image = UIImage(named: "pacman-female")
//        self.view.addSubview(UIImageView(image: image))

//        self.view.layer.masksToBounds = true;
        // Do any additional setup after loading the view.

//        self.view.backgroundColor = UIColor.clearColor()
//
//        var effect = UIBlurEffect(style: UIBlurEffectStyle.Light)
//        var blurView = UIVisualEffectView(effect: effect)
//
//        blurView.frame = self.view.bounds
//
//        self.view.addSubview(blurView)
//        self.view.sendSubviewToBack(blurView)


    }

    deinit {
        AudioManager.playMenuSound()
    }

}
