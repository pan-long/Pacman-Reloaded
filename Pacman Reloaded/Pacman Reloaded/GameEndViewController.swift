//
//  GameEndViewController.swift
//  Pacman Reloaded
//
//  Created by chuyu on 22/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import UIKit

protocol GameEndDelegate: class {
    func restart()
}

class GameEndViewController: MenuController {
    
    @IBOutlet weak var gameStatus: UILabel!
    var delegate: GameEndDelegate!

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
    
    @IBAction func restart(sender: UIButton) {
        delegate.restart()
    }
}
