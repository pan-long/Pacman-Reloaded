//
//  GameLevelDesignerCollectionViewLayout.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 9/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit

class GameLevelDesignerNormalCollectionViewLayout: GameLevelDesignerCollectionViewLayout {
    
    override func prepareLayout() {
        super.prepareLayout()
        width = Double(Constants.GameScene.GridWidth)
        height = Double(Constants.GameScene.GridHeight)
        rows = Double(Constants.GameScene.NumberOfRows)
        columns = Double(Constants.GameScene.NumberOfColumns)
    }
}
