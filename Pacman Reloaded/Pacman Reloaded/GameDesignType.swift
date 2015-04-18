//
//  GameDesignType.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 11/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation

enum GameDesignType: Int {
    case None = -1, PacmanMale, PacmanFemale, Inky, Blinky, Pinky, Clyde,
        Boundary, Pacdot, SuperPacdot, Eraser
    
    var image: String? {
        switch self {
        case .PacmanMale:
            return "pacman-male"
        case .PacmanFemale:
            return "pacman-female"
        case .Inky:
            return "ghost-blue-left"
        case .Blinky:
            return "ghost-red-left"
        case .Pinky:
            return "ghost-yellow-left"
        case .Clyde:
            return "ghost-orange-left"
        case .Pacdot:
            return "pacdot"
        case .SuperPacdot:
            return "super-pacdot-design"
        default:
            return nil
        }
    }
    
    var name: String? {
        switch self {
        case .PacmanMale:
            return "pacman"
        case .PacmanFemale:
            return "pacman"
        case .Inky:
            return "inky"
        case .Blinky:
            return "blinky"
        case .Pinky:
            return "pinky"
        case .Clyde:
            return "clyde"
        case .Pacdot:
            return "pacdot"
        case .Boundary:
            return "boundary"
        case .SuperPacdot:
            return "super-pacdot"
        default:
            return nil
        }
    }
    
    var isPacman: Bool {
        switch self {
        case .PacmanMale:
            return true
        case .PacmanFemale:
            return true
        default:
            return false
        }
    }
    
    var isGhost: Bool {
        switch self {
        case .Inky:
            return true
        case .Blinky:
            return true
        case .Pinky:
            return true
        case .Clyde:
            return true
        default:
            return false
        }
    }
}