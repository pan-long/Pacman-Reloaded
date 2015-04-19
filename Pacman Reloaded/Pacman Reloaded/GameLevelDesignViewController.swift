//
//  GameLevelDesignViewController.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 9/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit

class GameLevelDesignViewController: UIViewController {
    
    @IBOutlet weak var buttons: UIView!
    @IBOutlet weak var designArea: UICollectionView!
    @IBOutlet weak var miniMap: UICollectionView!
    @IBOutlet weak var miniMapRec: UIImageView!
    
    @IBOutlet weak var arrowUp: UIButton!
    @IBOutlet weak var arrowDown: UIButton!
    @IBOutlet weak var arrowLeft: UIButton!
    @IBOutlet weak var arrowRight: UIButton!
    private var arrowHolding: UIButton?
    private var arrowTimer: NSTimer?
    
    private let designAreaCellIdentifier = "levelDesignGrid"
    private let miniMapCellIdentifier = "levelDesignMinimapGrid"
    
    private var selected = GameDesignType.None
    private var cellMappings = Dictionary<NSIndexPath, GameDesignType>()
    
    private var numberOfPacmans = 0
    private var numberOfGhosts = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unselectAllButtons()
        designArea.registerClass(GameLevelDesignGridNormalCell.self,
            forCellWithReuseIdentifier: designAreaCellIdentifier)
        designArea.backgroundColor = UIColor.blackColor()
        designArea.dataSource = self
        designArea.delegate = self
        designArea.scrollEnabled = false
        designArea.layer.cornerRadius = CGFloat(20)

        miniMap.registerClass(GameLevelDesignGridCell.self,
            forCellWithReuseIdentifier: miniMapCellIdentifier)
        miniMap.backgroundColor = UIColor.blackColor()
        miniMap.delegate = self
        miniMap.dataSource = self
        miniMap.scrollEnabled = false
        
        arrowTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self,
                selector: "handleArrowLongPressing:", userInfo: nil, repeats: true)
        changeArrowVisibility()
    }
    
    deinit {
        println("Deinit level designer")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        miniMap.dataSource = nil
        miniMap.delegate = nil
        designArea.delegate = nil
        designArea.dataSource = nil
        arrowTimer?.invalidate()
        arrowTimer = nil
    }
    
    private func unselectAllButtons() {
        let allButtons = buttons.subviews as [UIView]
        for i in 0..<allButtons.count {
            allButtons[i].alpha = 0.5
        }
    }
    
    private func setCellToSelected(indexPath: NSIndexPath) {
        setCellToSelected(designArea, indexPath: indexPath)
        setCellToSelected(miniMap, indexPath: indexPath)
    }
    
    private func setCellToSelected(collectionView: UICollectionView, indexPath: NSIndexPath) {
        if let cellAtIndexPath = collectionView.cellForItemAtIndexPath(indexPath) {
            var cell = cellAtIndexPath as GameLevelDesignGridCell
            if collectionView == designArea {
                cell = cell as GameLevelDesignGridNormalCell
            }
            
            if let existing = cellMappings[indexPath] {
                if existing.isPacman {
                    numberOfPacmans--
                }
                if existing.isGhost {
                    numberOfGhosts--
                }
            }
            
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
            
            if selected == .None {
                cellMappings.removeValueForKey(indexPath)
            } else {
                cellMappings[indexPath] = selected
            }
            cell.setType(selected)
        }
    }
    
    private func changeArrowVisibility() {
        // Min and max x, y values for the design area
        let minX = Constants.GameScene.DesignAreaMinX
        let minY = Constants.GameScene.DesignAreaMinY
        let maxX = Constants.GameScene.DesignAreaMaxX
        let maxY = Constants.GameScene.DesignAreaMaxY
        let curX = designAreaCenter().x
        let curY = designAreaCenter().y

        arrowLeft.hidden = false
        arrowRight.hidden = false
        if curX <= minX {
            arrowLeft.hidden = true
        } else if curX >= maxX {
            arrowRight.hidden = true
        }
        
        arrowUp.hidden = false
        arrowDown.hidden = false
        if curY <= minY {
            arrowUp.hidden = true
        } else if curY >= maxY {
            arrowDown.hidden = true
        }
    }
    
    // Move the red rectangle in the minimap to an appropriate place
    // according to the current design area
    private func moveMiniMapRec() {
        let xRatio = designAreaCenter().x / Constants.GameScene.DesignAreaWidth
        let yRatio = designAreaCenter().y / Constants.GameScene.DesignAreaHeight
        let miniMapOrig = miniMap.frame.origin
        miniMapRec.center.x = miniMapOrig.x + miniMap.frame.width * xRatio
        miniMapRec.center.y = miniMapOrig.y + miniMap.frame.height * yRatio
    }
    
    // Move the design area to center around the given index path.
    private func moveDesignAreaToIndexPath(indexPath: NSIndexPath) {
        let curIndexPath = designArea.indexPathForItemAtPoint(designAreaCenter())!
        let cornerIndexPath = NSIndexPath(forRow: indexPath.row, inSection: curIndexPath.section)
        designArea.scrollToItemAtIndexPath(cornerIndexPath,
            atScrollPosition: .CenteredHorizontally, animated: false)
        designArea.scrollToItemAtIndexPath(indexPath,
            atScrollPosition: .CenteredVertically, animated: false)
    }
    
    private func designAreaCenter() -> CGPoint {
        return CGPoint(x: Constants.GameScene.DesignAreaMinX + designArea.contentOffset.x,
            y: Constants.GameScene.DesignAreaMinY + designArea.contentOffset.y)
    }
}

extension GameLevelDesignViewController {
    // Called by the presented controller
    func saveFileWithName(fileName: String) {
        GameLevelStorage.storeGameLevelToFile(cellMappings, fileName: fileName + ".xml")
    }
}


extension GameLevelDesignViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == designArea {
            setCellToSelected(indexPath)
        } else if collectionView == miniMap {
            moveDesignAreaToIndexPath(indexPath)
            moveMiniMapRec()
            changeArrowVisibility()
        }
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
        var cell: GameLevelDesignGridCell
        if collectionView == designArea {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(designAreaCellIdentifier, forIndexPath: indexPath) as GameLevelDesignGridNormalCell
        } else {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(miniMapCellIdentifier, forIndexPath: indexPath) as GameLevelDesignGridCell
        }
        
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
    
    @IBAction func handlePanGestureInMiniMap(sender: UIPanGestureRecognizer) {
        var currentPosition = sender.locationInView(miniMap)
        
        let minX = Constants.GameScene.RecCenterMinX
        let minY = Constants.GameScene.RecCenterMinY
        let maxX = Constants.GameScene.RecCenterMaxX
        let maxY = Constants.GameScene.RecCenterMaxY
        if currentPosition.x <= minX {
           currentPosition.x = minX
        }
        if currentPosition.y <= minY {
            currentPosition.y = minY
        }
        if currentPosition.x >= maxX {
            currentPosition.x = maxX
        }
        if currentPosition.y >= maxY {
            currentPosition.y = maxY
        }
        
        let miniMapOrig = miniMap.frame.origin
        miniMapRec.center.x = miniMapOrig.x + currentPosition.x
        miniMapRec.center.y = miniMapOrig.y + currentPosition.y
        
        let indexPath = miniMap.indexPathForItemAtPoint(currentPosition)!
        moveDesignAreaToIndexPath(indexPath)
        changeArrowVisibility()
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
            }
            break
        case arrowDown:
            if lastItem.section == Constants.GameScene.NumberOfRows - 1 {
                break
            } else {
                nextItem = lastItem.nextRow
                designArea.scrollToItemAtIndexPath(nextItem, atScrollPosition: .Bottom, animated: true)
            }
            break
        case arrowLeft:
            if firstItem.row == 0 {
                break
            } else {
                nextItem = firstItem.previousColumn
                designArea.scrollToItemAtIndexPath(nextItem, atScrollPosition: .Left, animated: true)
            }
            break
        case arrowRight:
            if lastItem.row == Constants.GameScene.NumberOfColumns - 1 {
                break
            } else {
                nextItem = lastItem.nextColumn
                designArea.scrollToItemAtIndexPath(nextItem, atScrollPosition: .Right, animated: true)
            }
            break
        default:
            break
        }
        
        changeArrowVisibility()
        moveMiniMapRec()
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