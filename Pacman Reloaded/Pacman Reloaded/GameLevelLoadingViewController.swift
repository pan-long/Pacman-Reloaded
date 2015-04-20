//
//  GameLevelLoadingViewController.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 19/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit

class GameLevelLoadingViewController: UIViewController {
    @IBOutlet var loadButton: UIButton!
    @IBOutlet var gameLevelsTable: UITableView!
    @IBOutlet var gameLevelPreview: UIImageView!
    let allFiles = GameLevelStorage.getGameLevels()
    
    var fileSelected: String?
    
    // by default it is in single player mode
    var isMultiplayerMode = false
    
    override func viewDidLoad() {
        gameLevelsTable.delegate = self
        gameLevelsTable.dataSource = self
        loadButton.enabled = false
    }
}

extension GameLevelLoadingViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        fileSelected = allFiles[indexPath.row]
        loadButton.enabled = true
        if let image = GameLevelStorage.getGameLevelImage(fileSelected!) {
            gameLevelPreview.image = image
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableCellIdentifier = Constants.Identifiers.GameLevelTableCell
        var cell = tableView.dequeueReusableCellWithIdentifier(tableCellIdentifier) as UITableViewCell
        cell.textLabel!.text = allFiles[indexPath.row]
        return cell
    }
}

extension GameLevelLoadingViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFiles.count
    }
}

extension GameLevelLoadingViewController {
    
    @IBAction func loadButtonClicked(sender: UIButton) {
        if let fileSelected = fileSelected {
            let presentingVC = self.presentingViewController as GameViewController
            let mapContent = GameLevelStorage.loadGameLevelFromFile(GameLevelStorage.addXMLExtensionToFile(fileSelected))

            presentingVC.setupSingleGame(fromMap: mapContent!)

            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}