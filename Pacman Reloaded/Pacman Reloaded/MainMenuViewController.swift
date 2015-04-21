//
//  MainMenuViewController.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 5/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    @IBOutlet weak var singlePlayerButton: UIButton!
    @IBOutlet weak var multiPlayerButton: UIButton!
    @IBOutlet weak var levelDesigner: UIButton!

    @IBOutlet weak var singlePlayerIcon: UIImageView!
    @IBOutlet weak var multiPlayerIcon: UIImageView!
    @IBOutlet weak var levelDesignerIcon: UIImageView!

    @IBOutlet weak var background: UIImageView!

    var animator: UIDynamicAnimator!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.animator = UIDynamicAnimator(referenceView: self.view)

        // Add parallax effect to background
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

        delay(1) {
            self.animateItems()
        }
    }

    func animateItems() {

        let buttons = [
            singlePlayerButton,
            multiPlayerButton,
            levelDesigner,
            singlePlayerIcon,
            multiPlayerIcon,
            levelDesignerIcon
        ]
        let points = [
            Constants.MainMenu.SinglePlayerCenter,
            Constants.MainMenu.MultiPlayerCenter,
            Constants.MainMenu.LevelDesignerCenter,
            Constants.MainMenu.SinglePlayerIconCenter,
            Constants.MainMenu.MultiPlayerIconCenter,
            Constants.MainMenu.LevelDesignerIconCenter
        ]
        animator.removeAllBehaviors()

        for i in 0..<buttons.count {
            let snapBehavior = UISnapBehavior(item: buttons[i], snapToPoint: points[i])
            snapBehavior.damping = 0.3
            animator.addBehavior(snapBehavior)
        }
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
        let buttons = [
            singlePlayerButton,
            multiPlayerButton,
            levelDesigner,
            singlePlayerIcon,
            multiPlayerIcon,
            levelDesignerIcon
        ]
        for i in 0..<buttons.count {
            buttons[i].frame.origin.y = Constants.MainMenu.OffscreenYPosition
        }

        delay(1) {
            self.animateItems()
        }
    }


}
