//
//  GameLevelSaveFileViewController.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 19/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit

class GameLevelSaveFileViewController: UIViewController {
    
    @IBOutlet weak var fileNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func saveFile(sender: UIButton) {
        let presentingVC = self.presentingViewController as GameLevelDesignViewController
        presentingVC.saveFileWithName(fileNameTextField.text)
        presentingVC.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: UIButton) {
        let presentingVC = self.presentingViewController as GameLevelDesignViewController
        presentingVC.dismissViewControllerAnimated(true, completion: { () -> Void in
            presentingVC.reloadInputViews()
        })
    }
    
    @IBAction func goToHomepage(sender: UIButton) {
        let presentingVC = self.presentingViewController as GameLevelDesignViewController
        presentingVC.dismissViewControllerAnimated(true, completion: { () -> Void in
            presentingVC.releaseMemory()
            let mainPageVC = presentingVC.presentingViewController!
            mainPageVC.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    deinit {
        println("Game level save file deinited")
    }
}