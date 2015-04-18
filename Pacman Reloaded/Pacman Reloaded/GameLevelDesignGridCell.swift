//
//  GameLevelDesignGridCell.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 11/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit

class GameLevelDesignGridCell: UICollectionViewCell {
    var width = Constants.GameScene.MiniGridWidth
    var height = Constants.GameScene.MiniGridHeight
    
    func setType(type: GameDesignType) {
        self.layer.backgroundColor = UIColor.blackColor().CGColor
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
        if let imageStr = type.image {
            let image = UIImage(named: imageStr)
            let imageView = UIImageView(image: image)
            imageView.frame = CGRectMake(0, 0, width, height)
            contentView.addSubview(imageView)
        } else if type == .Boundary {
            self.layer.backgroundColor = UIColor.yellowColor().CGColor
        }
    }
}
