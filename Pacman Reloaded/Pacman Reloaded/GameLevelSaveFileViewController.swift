//
//  GameLevelSaveFileViewController.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 19/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit

class GameLevelSaveFileViewController: MenuController {
    
    @IBOutlet weak var fileNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var warning1: UILabel!
    @IBOutlet weak var warning2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let presentingVC = self.presentingViewController as GameLevelDesignViewController
        if presentingVC.getNumberOfPacmans() == 0 {
            fileNameTextField.hidden = true
            saveButton.hidden = true
            warning1.hidden = false
            warning2.hidden = false
        } else {
            fileNameTextField.hidden = false
            saveButton.hidden = false
            warning1.hidden = true
            warning2.hidden = true
        }
    }
    
    @IBAction func saveFile(sender: UIButton) {
        let presentingVC = self.presentingViewController as GameLevelDesignViewController
        presentingVC.saveFileWithName(fileNameTextField.text)
        presentingVC.dismissViewControllerAnimated(true, completion: { () -> Void in
            presentingVC.releaseMemory()
            let mainPageVC = presentingVC.presentingViewController!
            mainPageVC.dismissViewControllerAnimated(true, completion: nil)
        })
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
    }
}