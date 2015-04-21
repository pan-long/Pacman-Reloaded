//
//  Ghost.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 17/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import SpriteKit

struct GhostName {
    static let GHOST_NAME_BLINKY = "BLINKY"
    static let GHOST_NAME_CLYDE = "CLYDE"
    static let GHOST_NAME_INKY = "INKY"
    static let GHOST_NAME_PINKY = "PINKY"
}

private enum GhostMode {
    case Normal, Frightened, Eaten
}

class Ghost: MovableObject {
    private var imageName: String = ""
    
    private var _currentMode: GhostMode = .Normal {
        didSet {
            updateTexture()
        }
    }
    
    var frightened: Bool {
        get {
            return _currentMode != .Normal
        }
        set (newValue) {
            if newValue && _currentMode == .Normal {
                _currentMode = .Frightened
                self.currentSpeed = Constants.Ghost.FrightenSpeed
                self.currentDir = self.currentDir.opposite
            } else if !newValue {
                _currentMode = .Normal
                self.currentSpeed = Constants.Ghost.Speed
            }
        }
    }
    
    var eaten: Bool {
        get {
            return _currentMode == .Eaten
        }
        set (newValue) {
            if newValue && _currentMode == .Frightened {
                _currentMode = .Eaten
                self.currentSpeed = Constants.Ghost.EatenSpeed
                self.currentDir = self.currentDir.opposite
            } else if !newValue {
                _currentMode = .Normal
            }
        }
    }
    
    init(id: Int, imageName: String) {
        super.init(id: id, image: imageName + Constants.Ghost.DefaultImageSuffix)
        self.imageName = imageName
        self.physicsBody?.categoryBitMask = GameObjectType.Ghost
        self.physicsBody?.contactTestBitMask = GameObjectType.PacMan | GameObjectType.Boundary
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody!.dynamic = true
        self.physicsBody!.friction = 0
        self.physicsBody!.restitution = 0 //bouncy
        self.physicsBody!.allowsRotation = false
        
        self.currentSpeed = Constants.Ghost.Speed
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func changeDirection(newDirection: Direction) {
        super.changeDirection(newDirection)
        updateTexture()
    }
    
    private func updateTexture() {
        if self.frightened && !self.eaten {
            self.sprite.texture = SKTexture(imageNamed: Constants.Ghost.FrightenedImage)
        } else if self.eaten {
            self.sprite.texture = SKTexture(imageNamed: Constants.Ghost.EatedImage)
        } else if self.currentDir != .None {
            self.sprite.texture = SKTexture(imageNamed: self.imageName +
                Constants.Ghost.ImageSeparator +
                self.currentDir.str.lowercaseString)
        } else {
            self.sprite.texture = SKTexture(imageNamed: self.imageName +
                Constants.Ghost.ImageSeparator +
                Direction.Default.str.lowercaseString)
            
        }
    }
    
}
