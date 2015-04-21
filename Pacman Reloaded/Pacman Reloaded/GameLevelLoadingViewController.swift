//
//  GameLevelLoadingViewController.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 19/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit

protocol GameLevelLoadingDelegate: class {

    func didSelectedLevel(sourceVC:UIViewController, mapContent: [Dictionary<String, String>], miniMapImage: UIImage)

    // Called before it is rewind to main menu,
    // give the presenting view controller a chance to clean up
    func willCancel(sourceVC: UIViewController)
}

class GameLevelLoadingViewController: UIViewController {
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var gameLevelsTable: UITableView!
    @IBOutlet weak var gameLevelPreview: UIImageView!
    
    let allFiles = GameLevelStorage.getGameLevels()
    
    var fileSelected: String?
    
    weak var delegate: GameLevelLoadingDelegate?
    
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
    @IBAction func cancelButtonClicked(sender: UIButton) {
        if let delegate = delegate {
            delegate.willCancel(self)
        }
        self.performSegueWithIdentifier(Constants.Identifiers.QuitLevelSelection, sender: self)
    }

    @IBAction func loadButtonClicked(sender: UIButton) {
        if let fileSelected = fileSelected {
            let mapContent = GameLevelStorage.loadGameLevelFromFile(GameLevelStorage.addXMLExtensionToFile(fileSelected))!
            let miniMapImage = GameLevelStorage.getGameLevelImage(Constants.GameScene.ImageWithoutBoundaryPrefix + fileSelected)!
            
            if let delegate = delegate {
                delegate.didSelectedLevel(self, mapContent: mapContent, miniMapImage: miniMapImage)
            }
        }
    }
}