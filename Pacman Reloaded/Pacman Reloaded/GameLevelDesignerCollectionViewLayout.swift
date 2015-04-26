//
//  GameLevelDesignerCollectionViewLayout.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 9/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit

class GameLevelDesignerCollectionViewLayout: UICollectionViewLayout {
    
    let half = 0.5
    var width = Double(Constants.LevelDesign.MiniMap.GridWidth)
    var height = Double(Constants.LevelDesign.MiniMap.GridHeight)
    var rows = Double(Constants.LevelDesign.NumberOfRows)
    var columns = Double(Constants.LevelDesign.NumberOfColumns)
    
    override func prepareLayout() {
        super.prepareLayout()
    }
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: columns * width, height: rows * height)
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        var attr = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        let row: Int = indexPath.section
        let column: Int = indexPath.row
        attr.center = CGPoint(x: width * (Double(column) + half),
            y: height * (Double(row) + half))
        attr.size = CGSize(width: width, height: height)
        return attr
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var results: [AnyObject] = []
        for var s=0; s<self.collectionView?.numberOfSections(); s++ {
            for var r=0; r<self.collectionView?.numberOfItemsInSection(s); r++ {
                let indexPath = NSIndexPath(forItem: r, inSection: s)
                let layoutAttr = layoutAttributesForItemAtIndexPath(indexPath)
                results.append(layoutAttr)
            }
        }
        return results
    }
}
