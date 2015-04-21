//
//  MainMenuViewController.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 5/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    @IBOutlet weak var background: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let leftRightEffect = UIInterpolatingMotionEffect(keyPath: Constants.MainMenu.ParallaxLeftRightKeyPath,
            type: UIInterpolatingMotionEffectType.TiltAlongHorizontalAxis)
        let upDownEffect = UIInterpolatingMotionEffect(keyPath: Constants.MainMenu.ParallaxUpDownKeyPath,
            type: UIInterpolatingMotionEffectType.TiltAlongVerticalAxis)

        leftRightEffect.minimumRelativeValue = Constants.MainMenu.ParallaxLeftRightMin
        leftRightEffect.maximumRelativeValue = Constants.MainMenu.ParallaxLeftRightMax
        upDownEffect.minimumRelativeValue = Constants.MainMenu.ParallaxUpDownMin
        upDownEffect.maximumRelativeValue = Constants.MainMenu.ParallaxUpDownMax

        let motionGroup = UIMotionEffectGroup()
        motionGroup.motionEffects = [leftRightEffect, upDownEffect]

        background.addMotionEffect(motionGroup)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {

    }


}
