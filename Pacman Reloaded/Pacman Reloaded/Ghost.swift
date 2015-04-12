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
                self.currentDir = self.currentDir.opposite
            } else if !newValue {
                _currentMode = .Normal
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
                self.currentDir = self.currentDir.opposite
            } else if !newValue {
                _currentMode = .Normal
            }
        }
    }
    
    convenience init(imageName: String) {
        self.init(image: imageName + Constants.Ghost.defaultImageSuffix)
        self.imageName = imageName
        self.physicsBody?.categoryBitMask = GameObjectType.Ghost
        self.physicsBody?.contactTestBitMask = GameObjectType.PacMan | GameObjectType.Boundary
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody!.dynamic = true
        self.physicsBody!.friction = 0
        self.physicsBody!.restitution = 0 //bouncy
        self.physicsBody!.allowsRotation = false
        
        self.currentSpeed = Constants.Ghost.speed
    }
    
    override func changeDirection(newDirection: Direction) {
        super.changeDirection(newDirection)
        updateTexture()
    }
    
    private func updateTexture() {
        if self.frightened && !self.eaten {
            self.sprite.texture = SKTexture(imageNamed: Constants.Ghost.frightenedImage)
        } else if self.eaten {
            self.sprite.texture = SKTexture(imageNamed: Constants.Ghost.eatedImage)
        } else if self.currentDir != .None {
            self.sprite.texture = SKTexture(imageNamed: self.imageName +
                Constants.Ghost.imageSeparator +
                self.currentDir.str.lowercaseString)
        } else {
            self.sprite.texture = SKTexture(imageNamed: self.imageName +
                Constants.Ghost.imageSeparator +
                Direction.Default.str.lowercaseString)
            
        }
    }
    
}
