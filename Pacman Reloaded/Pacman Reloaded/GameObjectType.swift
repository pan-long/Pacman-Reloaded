//
//  GameObjectType.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 17/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//


struct GameObjectType {
    static let None: UInt32 = 0
    static let PacMan: UInt32 = 0b10
    static let Ghost: UInt32 = 0b100
    static let PacDot: UInt32 = 0b1000
    static let Boundary: UInt32 = 0b10000
}
