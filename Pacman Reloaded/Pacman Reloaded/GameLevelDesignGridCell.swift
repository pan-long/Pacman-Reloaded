//
//  GameLevelDesignGridCell.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 11/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit

class GameLevelDesignGridCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderColor = UIColor.grayColor().CGColor
        self.layer.borderWidth = 0.3
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TODO Set wall type.
    func setType(type: GameDesignType) {
        self.layer.backgroundColor = UIColor.blackColor().CGColor
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
        if let imageStr = type.image {
            let width = Constants.GameScene.GridWidth
            let height = Constants.GameScene.GridHeight
            let image = UIImage(named: imageStr)
            let imageView = UIImageView(image: image)
            imageView.frame = CGRectMake(0, 0, width, height)
            contentView.addSubview(imageView)
        } else if type == .Wall {
            self.layer.backgroundColor = UIColor.yellowColor().CGColor
        }
    }
}
