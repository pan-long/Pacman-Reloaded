//
//  GameLevelDesignGridNormalCell.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 13/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit

class GameLevelDesignGridNormalCell: GameLevelDesignGridCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        width = Constants.GameScene.GridWidth
        height = Constants.GameScene.GridHeight
        self.layer.borderColor = UIColor.grayColor().CGColor
        self.layer.borderWidth = 0.3
    }

    required override init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}