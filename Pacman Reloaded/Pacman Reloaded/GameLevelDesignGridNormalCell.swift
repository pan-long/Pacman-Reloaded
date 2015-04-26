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
        width = Constants.LevelDesign.DesignArea.GridWidth
        height = Constants.LevelDesign.DesignArea.GridHeight
        self.layer.borderColor = UIColor.grayColor().CGColor
        self.layer.borderWidth = Constants.LevelDesign.DesignArea.GridBorderWidth
    }

    required override init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}