//
//  Direction.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 17/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation

enum Direction {
    case Up, Down, Left, Right, None

    func getRotation() -> Double {
        switch self {
        case .Right:
            return DegreesToRadians(0)
        case .Left:
            return DegreesToRadians(180)
        case .Up:
            return DegreesToRadians(90)
        case .Down:
            return DegreesToRadians(-90)
        case .None:
            return DegreesToRadians(0)
        }
    }
}


func DegreesToRadians (value:Double) -> Double {
    return value * M_PI / 180.0
}

