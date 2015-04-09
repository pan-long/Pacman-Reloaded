//
//  GamePopoverViewController.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 5/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import UIKit

class GamePopoverViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navCtrl = UINavigationController(rootViewController: self)
        navCtrl.pushViewController(self, animated: true)
        navCtrl.navigationBar.topItem?.title = "Game Settings"
        self.presentViewController(navCtrl, animated: true, completion: nil)
        
        // Add navigation bar.

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
