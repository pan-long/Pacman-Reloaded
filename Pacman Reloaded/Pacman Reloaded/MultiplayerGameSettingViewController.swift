//
//  MultiplayerGameSettingViewController.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 5/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//


import SpriteKit

class MultiplayerGameSettingViewController: GamePopoverViewController {
    
    @IBOutlet var numberOfPlayersStepper: UIStepper!
    @IBOutlet var numberOfPlayersLabel: UILabel!
    @IBOutlet var confirmButton: UIButton!
    
    override func viewDidLoad() {
        numberOfPlayersStepper.maximumValue = 8.0
        numberOfPlayersStepper.minimumValue = 2.0
        numberOfPlayersLabel.text = "Number of Players: \(Int(numberOfPlayersStepper.value))"
    }
    
    @IBAction func numberOfPlayersChanged(sender: AnyObject) {
        let stepper = sender as UIStepper
        numberOfPlayersLabel.text = "Number of Players: \(Int(stepper.value))"

    }
    
    @IBAction func confirmButtonClicked(sender: AnyObject) {
        let presentingVC = self.presentingViewController as MultiplayerGameViewController
        presentingVC.setNumberOfPlayers(Int(numberOfPlayersStepper.value))
    }
}