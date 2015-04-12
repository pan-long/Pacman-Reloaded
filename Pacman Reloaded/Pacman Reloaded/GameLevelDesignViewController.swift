//
//  GameLevelDesignViewController.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 9/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit

class GameLevelDesignViewController: UIViewController {
    
    // TODO Handle the memory issue.
    @IBOutlet weak var buttons: UIView!
    @IBOutlet weak var designArea: UICollectionView!
    @IBOutlet weak var miniMap: UIView!
    
    @IBOutlet weak var arrowUp: UIButton!
    @IBOutlet weak var arrowDown: UIButton!
    @IBOutlet weak var arrowLeft: UIButton!
    @IBOutlet weak var arrowRight: UIButton!
    private var arrowHolding: UIButton?
    private var arrowTimer: NSTimer?
    
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
        designArea.layer.cornerRadius = CGFloat(20)
        
        miniMap.backgroundColor = UIColor.blackColor()
        miniMap.layer.cornerRadius = CGFloat(10)
        
        // Initially the left and up arrows should be hidden.
        arrowUp.hidden = true
        arrowLeft.hidden = true
        arrowTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self,
                selector: "handleArrowLongPressing:", userInfo: nil, repeats: true)
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
    
    private func setCellToSelected(indexPath: NSIndexPath) {
        setCellToSelected(designArea, indexPath: indexPath)
        
    }
    
    private func setCellToSelected(collectionView: UICollectionView, indexPath: NSIndexPath) {
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


extension GameLevelDesignViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        setCellToSelected(collectionView, indexPath: indexPath)
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
            case Constants.GameScene.BoundaryTag:
                selected = GameDesignType.Boundary
                break
            case Constants.GameScene.PacdotTag:
                selected = GameDesignType.Pacdot
                break
            case Constants.GameScene.SuperPacdotTag:
                selected = GameDesignType.SuperPacdot
                break
            case Constants.GameScene.EraserTag:
                selected = GameDesignType.None
                break
            default:
                break
            }
            unselectAllButtons()
            button.alpha = 1 // TODO Refactor
        }
    }
    
    @IBAction func handlePanGesture(sender: UIPanGestureRecognizer) {
        // Pan gesture is only applicable to these three types
        if selected == .Boundary || selected == .Pacdot || selected == .None {
            let currentPosition = sender.locationInView(designArea)
            if let indexPath = designArea.indexPathForItemAtPoint(currentPosition) {
                setCellToSelected(indexPath)
            }
        }
    }
    
    @IBAction func saveFile(sender: UIButton) {
        GameLevelStorage.storeGameLevelToFile(cellMappings, fileName: "myFirstFile.xml")
    }
}

// This extension deals with the arrows.
extension GameLevelDesignViewController {
    func moveDesignArea(toDirection arrow: UIButton) {
        let visibleItems = designArea.indexPathsForVisibleItems().sorted(gameLevelIndexPathComparator)
        let firstItem = visibleItems.first as NSIndexPath
        let lastItem = visibleItems.last as NSIndexPath
        var nextItem: NSIndexPath
        
        switch arrow {
        case arrowUp:
            if firstItem.section == 0 {
                break
            } else {
                nextItem = firstItem.previousRow
                designArea.scrollToItemAtIndexPath(nextItem, atScrollPosition: .Top, animated: true)
                
                arrowDown.hidden = false
                if nextItem.section == 0 {
                    arrowUp.hidden = true
                } else {
                    arrowUp.hidden = false
                }
            }
            break
        case arrowDown:
            if lastItem.section == Constants.GameScene.NumberOfRows - 1 {
                break
            } else {
                nextItem = lastItem.nextRow
                designArea.scrollToItemAtIndexPath(nextItem, atScrollPosition: .Bottom, animated: true)
                
                arrowUp.hidden = false
                if nextItem.section == Constants.GameScene.NumberOfRows - 1 {
                    arrowDown.hidden = true
                } else {
                    arrowDown.hidden = false
                }
            }
            break
        case arrowLeft:
            if firstItem.row == 0 {
                break
            } else {
                nextItem = firstItem.previousColumn
                designArea.scrollToItemAtIndexPath(nextItem, atScrollPosition: .Left, animated: true)
                
                arrowRight.hidden = false
                if nextItem.row == 0 {
                    arrowLeft.hidden = true
                } else {
                    arrowLeft.hidden = false
                }
            }
            break
        case arrowRight:
            if lastItem.row == Constants.GameScene.NumberOfColumns - 1 {
                break
            } else {
                nextItem = lastItem.nextColumn
                designArea.scrollToItemAtIndexPath(nextItem, atScrollPosition: .Right, animated: true)
                
                arrowLeft.hidden = false
                if nextItem.row == Constants.GameScene.NumberOfColumns - 1 {
                    arrowRight.hidden = true
                } else {
                    arrowRight.hidden = false
                }
            }
            break
        default:
            break
        }
    }
    
    // Click an arrow
    @IBAction func arrowClicked(sender: AnyObject) {
        moveDesignArea(toDirection: (sender as UIButton))
    }
    
    // Long pressing an arrow
    @IBAction func arrowLongPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .Began {
            arrowHolding = (sender.view as UIButton)
        } else if sender.state == .Ended {
            arrowHolding = nil
        }
    }
    
    func handleArrowLongPressing(timer: NSTimer) {
        if let arrow = arrowHolding {
            moveDesignArea(toDirection: arrow)
        }
    }
}