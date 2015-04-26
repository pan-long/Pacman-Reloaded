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

class GameLevelLoadingViewController: MenuController {
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var gameLevelsTable: UITableView!
    @IBOutlet weak var gameLevelPreview: UIImageView!
    
    private let allPredefinedFiles = GameLevelStorage.getPredefinedGameLevels()
    private let allFiles = GameLevelStorage.getGameLevels()
    
    private var fileSelected: Int?
    
    weak var delegate: GameLevelLoadingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameLevelsTable.delegate = self
        gameLevelsTable.dataSource = self
        gameLevelsTable.layer.cornerRadius = Constants.Table.CornerRadius
        gameLevelsTable.alpha = Constants.Table.Alpha
        loadButton.enabled = false
        fileSelected = 0
    }
    
    private func getSelectedFileName() -> String {
        var fileName: String
        if fileSelected < allPredefinedFiles.count {
            fileName = allPredefinedFiles[fileSelected!]
        } else {
            fileName = allFiles[fileSelected! - allPredefinedFiles.count]
        }
        return fileName
    }
    
    private func getSelectedFileImage() -> UIImage {
        var image: UIImage
        let fileName = getSelectedFileName()
        if fileSelected < allPredefinedFiles.count {
            image = GameLevelStorage.getPredefinedGameLevelImage(fileName)!
        } else {
            image = GameLevelStorage.getGameLevelImage(fileName)!
        }
        return image
    }
    
    private func getSelectedFileImageWithoutPacdots() -> UIImage {
        var image: UIImage
        let prefix = Constants.LevelDesign.ImageWithoutBoundaryPrefix
        let fileName = getSelectedFileName()
        if fileSelected < allPredefinedFiles.count {
            image = GameLevelStorage.getPredefinedGameLevelImage(prefix + fileName)!
        } else {
            image = GameLevelStorage.getGameLevelImage(prefix + fileName)!
        }
        return image
    }
    
    private func getSelectedFileContent() -> [Dictionary<String, String>] {
        var content: [Dictionary<String, String>]
        if fileSelected < allPredefinedFiles.count {
            content = GameLevelStorage.loadGameLevelFromPredefinedFile(allPredefinedFiles[fileSelected!])!
        } else {
            content = GameLevelStorage.loadGameLevelFromFile(allFiles[fileSelected! - allPredefinedFiles.count])!
        }
        return content
    }
}

extension GameLevelLoadingViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        fileSelected = indexPath.row
        loadButton.enabled = true
        gameLevelPreview.image = getSelectedFileImage()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableCellIdentifier = Constants.Identifiers.GameLevelTableCell
        var cell = tableView.dequeueReusableCellWithIdentifier(tableCellIdentifier) as UITableViewCell
        if indexPath.row < allPredefinedFiles.count {
            cell.textLabel!.text = allPredefinedFiles[indexPath.row]
        } else {
            cell.textLabel!.text = allFiles[indexPath.row - allPredefinedFiles.count]
        }

        return cell
    }
}

extension GameLevelLoadingViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPredefinedFiles.count + allFiles.count
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
            let mapContent = getSelectedFileContent()
            let miniMapImage = getSelectedFileImageWithoutPacdots()
            
            if let delegate = delegate {
                delegate.didSelectedLevel(self, mapContent: mapContent, miniMapImage: miniMapImage)
            }
        }
    }
}