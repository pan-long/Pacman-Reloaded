//
//  GameMenuViewController.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 5/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import UIKit

class GameMenuViewController: MenuController {

    override func viewDidLoad() {
        super.viewDidLoad()

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

    @IBAction func cancelButtonPressed(sender: UIButton) {
        let presentingVC = self.presentingViewController? as? GameViewController
        presentingVC?.resume()
    }

    @IBAction func quitButtonPressed(sender: UIButton) {
        let presentingVC = self.presentingViewController? as? GameViewController
        presentingVC?.quit()

    }
    
    @IBAction func restartButtonPressed(sender: UIButton) {
        let presentingVC = self.presentingViewController? as? GameViewController
        presentingVC?.restart()
    }
}
