//
//  Direction.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 17/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation

enum Direction: String {
    case Up = "Up", Down = "Down", Left = "Left", Right = "Right", None = "None"

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

    var str: String {
        switch self {
        case .Right:
            return "Right"
        case .Left:
            return "Left"
        case .Down:
            return "Down"
        case .Up:
            return "Up"
        case .None:
            return "None"
        }
    }
    
    static var directionArray: [Direction] {
        return [Direction.Up, Direction.Down, Direction.Left, Direction.Right]
    }
    
    static func getRandomDirection() -> Direction {
        var direction = directionArray[random() % 4]
        return direction
    }
}


func DegreesToRadians (value:Double) -> Double {
    return value * M_PI / 180.0
}

