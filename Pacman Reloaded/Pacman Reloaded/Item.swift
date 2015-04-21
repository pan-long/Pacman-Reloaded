//
//  Item.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 17/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation

class Item: GameObject {
    init(id: Int, image: String) {
        super.init(id: id, image: image, sizeScale: Constants.Item.SizeScale)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

