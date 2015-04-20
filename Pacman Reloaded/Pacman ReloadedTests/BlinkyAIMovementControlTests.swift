//
//  BlinkyAIMovementControlTests.swift
//  Pacman Reloaded
//
//  Created by chuyu on 12/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import UIKit
import XCTest

class BlinkyAIMovementControlTests: XCTestCase {
    private var blinky = Ghost(id: 0, imageName: "ghost-red")
    private var pinky = Ghost(id: 1, imageName: "ghost-yellow")
    private var inky = Ghost(id: 2, imageName: "ghost-blue")
    private var clyde = Ghost(id: 3,imageName: "ghost-orange")
    private let pacman = PacMan(id: 4)
    
    private var ghosts: [MovableObject]!
    private var pacmans: [MovableObject]!
    
    private var blinkyMovement: BlinkyAIMovememntControl!
    
    private func constructBlinkyAIMovementControl() {
        ghosts = [blinky, pinky, inky, clyde]
        pacmans = [pacman]
        blinkyMovement = BlinkyAIMovememntControl(movableObject: blinky)
        blinkyMovement.dataSource = self
    }
    
    func testCheckUpdateFrame() {
        constructBlinkyAIMovementControl()
        
        blinky.position = CGPoint(
            x: Constants.AIMovementControl.GAME_SCENE_MAX_X,
            y: Constants.AIMovementControl.GAME_SCENE_MAX_Y - 1)
        blinkyMovement.update()
        XCTAssertEqual(blinky.currentDir, Direction.Right, "Can check update frame correctly")
        
        blinkyMovement.update()
        XCTAssertEqual(blinky.currentDir, Direction.Up, "Can check update frame correctly")
    }
}

extension BlinkyAIMovementControlTests: MovementDataSource {
    func getPacmans() -> [MovableObject] {
        var pacmans = [MovableObject]()
        pacmans.append(pacman)
        return pacmans
    }
    
    func getBlinkys() -> [MovableObject] {
        return [blinky]
    }
}