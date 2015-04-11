//
//  GameLevelDesignViewController.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 9/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit

class GameLevelDesignViewController: UIViewController {
    
    @IBOutlet var buttons: UIView!
    @IBOutlet var designArea: UICollectionView!
    
    @IBOutlet var arrowUp: UIButton!
    @IBOutlet var arrowDown: UIButton!
    @IBOutlet var arrowLeft: UIButton!
    @IBOutlet var arrowRight: UIButton!
    
    private let cellIdentifier = "levelDesignGrid"
    private var selected = GameDesignType.None
    private var cellMappings = Dictionary<NSIndexPath, GameDesignType>()
    private var numberOfPacmans = 0
    private var numberOfGhosts = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unselectAllButtons()
        designArea.registerClass(GameLevelDesignGridCell.self,
            forCellWithReuseIdentifier: cellIdentifier)
        designArea.backgroundColor = UIColor.blackColor()
        designArea.dataSource = self
        designArea.delegate = self
        designArea.scrollEnabled = false
        designArea.layer.cornerRadius = CGFloat(19)
    }
    
    private func setupArrows() {
        let visibleItems = designArea.indexPathsForVisibleItems()
            .sorted({ (o1: AnyObject, o2: AnyObject) -> Bool in
                let first = o1 as NSIndexPath
                let second = o2 as NSIndexPath
                var result: Bool
                if first.section < second.section {
                    result = true
                } else if first.section == second.section {
                    result = first.row < second.row
                } else {
                    result = false
                }
                return result
        })
        let firstItem = visibleItems.first as NSIndexPath
        let lastItem = visibleItems.last as NSIndexPath
        
        if firstItem.section == 0 {
            arrowUp.hidden = true
        } else {
            arrowUp.hidden = false
        }
        
        if firstItem.row == 0 {
            arrowLeft.hidden = true
        } else {
            arrowLeft.hidden = false
        }
        
        if lastItem.section == 19 {
            arrowDown.hidden = true
        } else {
            arrowDown.hidden = false
        }
        
        if lastItem.row == 29 {
            arrowRight.hidden = true
        } else {
            arrowRight.hidden = false
        }
        
        designArea.scrollToItemAtIndexPath(lastItem, atScrollPosition: .Top, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func unselectAllButtons() {
        let allButtons = buttons.subviews as [UIView]
        for i in 0..<allButtons.count {
            allButtons[i].alpha = 0.5
        }
    }
}


extension GameLevelDesignViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println(indexPath)
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as GameLevelDesignGridCell
        if selected.isPacman {
            if numberOfPacmans >= Constants.GameScene.MaxNumberOfPacman {
                return
            } else {
                numberOfPacmans++
            }
        }
        if selected.isGhost {
            if numberOfGhosts >= Constants.GameScene.MaxNumberOfGhosts {
                return
            } else {
                numberOfGhosts++
            }
        }
        
        if let existing = cellMappings[indexPath] {
            if existing.isPacman {
                numberOfPacmans--
            }
            if existing.isGhost {
                numberOfGhosts--
            }
        }
        
        if selected == .None {
            cellMappings.removeValueForKey(indexPath)
        } else {
            cellMappings[indexPath] = selected
        }
        cell.setType(selected)
    }
}

extension GameLevelDesignViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return Constants.GameScene.NumberOfRows
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.GameScene.NumberOfColumns
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as GameLevelDesignGridCell
        if let cellType = cellMappings[indexPath] {
            cell.setType(cellMappings[indexPath]!)
        } else {
            cell.setType(GameDesignType.None)
        }
        return cell
    }
}

extension GameLevelDesignViewController {
    // Handle clicking on the buttons.
    @IBAction func designButtonClicked(sender: AnyObject) {
        if let button = sender as? UIButton {
            switch button.tag {
            case Constants.GameScene.PacmanMaleTag:
                selected = GameDesignType.PacmanMale
                break
            case Constants.GameScene.PacmanFemaleTag:
                selected = GameDesignType.PacmanFemale
                break
            case Constants.GameScene.InkyTag:
                selected = GameDesignType.Inky
                break
            case Constants.GameScene.BlinkyTag:
                selected = GameDesignType.Blinky
                break
            case Constants.GameScene.PinkyTag:
                selected = GameDesignType.Pinky
                break
            case Constants.GameScene.ClydeTag:
                selected = GameDesignType.Clyde
                break
            case Constants.GameScene.WallTag:
                selected = GameDesignType.Wall
                break
            case Constants.GameScene.EraserTag:
                selected = GameDesignType.None
                break
            default:
                break
            }
            unselectAllButtons()
            button.alpha = 1
        }
    }
    
    @IBAction func arrowClicked(sender: AnyObject) {
        setupArrows()
    }
    
}