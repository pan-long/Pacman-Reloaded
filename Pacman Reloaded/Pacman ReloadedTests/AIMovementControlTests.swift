//
//  AIMovementControlTests.swift
//  Pacman Reloaded
//
//  Created by chuyu on 20/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import UIKit
import XCTest

import UIKit
import XCTest

class AIMovementControlTests: XCTestCase {
    private let MAX_DISTANCE: Double = 10000
    
    private let blinkyHome = CGPoint(
        x: Constants.AIMovementControl.GAME_SCENE_MIN_X,
        y: Constants.AIMovementControl.GAME_SCENE_MAX_Y)
    
    private var blinky1 = Ghost(imageName: "ghost-red")
    private var blinky2 = Ghost(imageName: "ghost-red")
    private var pinky1 = Ghost(imageName: "ghost-yellow")
    private var pinky2 = Ghost(imageName: "ghost-yellow")
    private var inky1 = Ghost(imageName: "ghost-blue")
    private var inky2 = Ghost(imageName: "ghost-blue")
    private var clyde1 = Ghost(imageName: "ghost-orange")
    private var clyde2 = Ghost(imageName: "ghost-orange")
    private let pacman1 = PacMan()
    private let pacman2 = PacMan()
    
    private var ghosts: [MovableObject]!
    private var pacmans: [MovableObject]!
    
    private var blinkyMovement: BlinkyAIMovememntControl!
    
    private func calculateDistance(firstPostion: CGPoint, secondPostion: CGPoint) -> Double  {
        let distanceX = Double(firstPostion.x) - Double(secondPostion.x)
        let distanceY = Double(firstPostion.y) - Double(secondPostion.y)
        return sqrt(distanceX * distanceX + distanceY * distanceY)
    }
    
    private func getOptimalDirection(movableObject: MovableObject, directions: [Direction], destination: CGPoint) -> Direction {
        var optimalDirection: Direction!
        var minDistance: Double = MAX_DISTANCE
            
        for direction in directions {
            let distance = calculateDistance(
                movableObject.getNextPosition(direction, offset: 1),
                secondPostion: destination)
            
            if distance < minDistance {
                minDistance = distance
                optimalDirection = direction
            }
        }
        
        return optimalDirection
    }
    
    private func finishUpdateBuffer(movement: AIMovementControl, mode: GhostMovementMode, buffer: Int) {
        for i in 0..<buffer {
            switch mode {
            case .Chase:
                movement.chaseUpdate()
            case .Scatter:
                movement.scatterUpdate()
            case .Frightened:
                movement.frightenUpdate()
            }
        }
    }
    
    func testBlinkyScatterMode() {
        let blinkyMovement1 = BlinkyAIMovememntControl(movableObject: blinky1)
        blinkyMovement1.dataSource = self
        let blinkyMovement2 = BlinkyAIMovememntControl(movableObject: blinky2)
        blinkyMovement2.dataSource = self
        
        blinky1.position = CGPointMake(CGFloat(1300), CGFloat(500))
        blinky2.position = CGPointMake(CGFloat(200), CGFloat(300))
        
        // Tests for blinky1 in scatter mode
        blinkyMovement1.scatterUpdate()
        XCTAssertEqual(blinky1.currentDir, Direction.Up, "Blinky scatter mode incorrectly change Blinky's direction")
        
        blinky1.changeDirection(.Down)
        blinkyMovement1.scatterUpdate()
        XCTAssertEqual(blinky1.currentDir, Direction.Down, "Blinky scatter mode incorrectly check update frame")
        
        blinky1.currentDir = .None
        blinky1.blocked.up = 1
        blinkyMovement1.scatterUpdate()
        XCTAssertEqual(blinky1.currentDir, Direction.Right, "Blinky scatter mode does not update when there are no paths")
        
        finishUpdateBuffer(blinkyMovement1, mode: GhostMovementMode.Scatter, buffer: 4)
        
        blinkyMovement1.scatterUpdate()
        XCTAssertEqual(blinky1.currentDir, Direction.Up, "Blinky scatter mode incorrectly resume update frame")
        
        blinky1.blocked = (up: 1, down: 0, left: 1, right: 1)
        blinkyMovement1.scatterUpdate()
        XCTAssertEqual(blinky1.currentDir, Direction.Down, "Blinky scatter mode incorrectly reverse direction in dead end")
        
        // Tests for blinky2 in scatter mode
        blinkyMovement2.scatterUpdate()
        XCTAssertEqual(blinky2.currentDir, Direction.Right, "Blinky scatter mode incorrectly change Blinky's direction")
        
        blinky2.changeDirection(.Down)
        blinkyMovement2.scatterUpdate()
        XCTAssertEqual(blinky2.currentDir, Direction.Right, "Blinky scatter mode incorrectly check update frame")
        
        pacman1.position = CGPointMake(CGFloat(200), CGFloat(304))
        blinkyMovement2.scatterUpdate()
        XCTAssertEqual(blinky2.currentDir, Direction.Right, "Blinky scatter mode is affected by Pacman's position")
    }
    
    func testBlinkyChaseMode() {
        let blinkyMovement1 = BlinkyAIMovememntControl(movableObject: blinky1)
        blinkyMovement1.dataSource = self
        let blinkyMovement2 = BlinkyAIMovememntControl(movableObject: blinky2)
        blinkyMovement2.dataSource = self
        
        blinky1.position = CGPointMake(CGFloat(1300), CGFloat(500))
        blinky2.position = CGPointMake(CGFloat(200), CGFloat(300))
        
        pacman1.position = CGPointMake(CGFloat(1308), CGFloat(500))
        pacman2.position = CGPointMake(CGFloat(1300), CGFloat(504))
        
        // Tests for blinky1 in chase mode
        blinkyMovement1.chaseUpdate()
        XCTAssertEqual(blinky1.currentDir, Direction.Up, "Blinky chase mode corrctly chase the nearest pacman")
        
        blinky1.changeDirection(Direction.Down)
        blinkyMovement1.chaseUpdate()
        XCTAssertEqual(blinky1.currentDir, Direction.Down, "Blinky chase mode incorrectly check update frame")
        
        finishUpdateBuffer(blinkyMovement1, mode: GhostMovementMode.Chase, buffer: 3)
        
        blinkyMovement1.chaseUpdate()
        XCTAssertNotEqual(blinky1.currentDir, Direction.Down, "Blinky chase mode incorrectly resume update frame")
        
        
        // Tests for blinky2 in chase mode
        pacman1.position = CGPointMake(CGFloat(200), CGFloat(290))
        pacman2.position = CGPointMake(CGFloat(180), CGFloat(300))
        
        blinkyMovement2.chaseUpdate()
        XCTAssertEqual(blinky2.currentDir, Direction.Down, "Blinky chase mode incorrectly change Blinky's direction")
        
        finishUpdateBuffer(blinkyMovement1, mode: GhostMovementMode.Scatter, buffer: 4)
        blinky2.blocked.down = 1
        blinkyMovement2.chaseUpdate()
        XCTAssertEqual(blinky2.currentDir, Direction.Down, "Blinky chase mode incorrectly chase nearest pacman")
        
        blinky2.blocked = (up: 0, down: 1, left: 1, right: 1)
        blinkyMovement2.chaseUpdate()
        XCTAssertEqual(blinky2.currentDir, Direction.Up, "Blinky scatter mode incorrectly reverse direction in dead end")
    }
}

extension AIMovementControlTests: MovementDataSource {
    func getPacmans() -> [MovableObject] {
        var pacmans = [MovableObject]()
        pacmans.append(pacman1)
        pacmans.append(pacman2)
        return pacmans
    }
    
    func getBlinkys() -> [MovableObject] {
        return [blinky1, blinky2]
    }
}
