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
    
    private var blinky1 = Ghost(id: 0, imageName: "ghost-red")
    private var blinky2 = Ghost(id: 1, imageName: "ghost-red")
    private var pinky1 = Ghost(id: 2, imageName: "ghost-yellow")
    private var pinky2 = Ghost(id: 3, imageName: "ghost-yellow")
    private var inky1 = Ghost(id: 4, imageName: "ghost-blue")
    private var inky2 = Ghost(id: 5, imageName: "ghost-blue")
    private var clyde1 = Ghost(id: 6, imageName: "ghost-orange")
    private var clyde2 = Ghost(id: 7, imageName: "ghost-orange")
    private let pacman1 = PacMan(id: 8)
    private let pacman2 = PacMan(id: 9)
    
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
        
        finishUpdateBuffer(blinkyMovement2, mode: GhostMovementMode.Scatter, buffer: 4)
        blinky2.blocked.down = 1
        blinkyMovement2.chaseUpdate()
        XCTAssertEqual(blinky2.currentDir, Direction.Left, "Blinky chase mode incorrectly chase nearest pacman")
        
        blinky2.blocked = (up: 1, down: 1, left: 1, right: 0)
        blinkyMovement2.chaseUpdate()
        XCTAssertEqual(blinky2.currentDir, Direction.Right, "Blinky chase mode incorrectly reverse direction in dead end")
    }
    
    func testFrightenedMode() {
        let blinkyMovement1 = BlinkyAIMovememntControl(movableObject: blinky1)
        blinkyMovement1.dataSource = self
        
        blinky1.position = CGPointMake(CGFloat(1300), CGFloat(500))
        
        blinky1.changeDirection(Direction.Left)
        blinky1.blocked = (up: 1, left: 0, right: 1, down: 1)
        blinkyMovement1.frightenUpdate()
        XCTAssertEqual(blinky1.currentDir, Direction.Left, "Blinky frighened mode incorrectly reverse direction in dead end")
    }
    
    func testPinkyScatterMode() {
        let pinkyMovement1 = PinkyAIMovementControl(movableObject: pinky1)
        pinkyMovement1.dataSource = self
        let pinkyMovement2 = PinkyAIMovementControl(movableObject: pinky2)
        pinkyMovement2.dataSource = self
        
        pinky1.position = CGPointMake(CGFloat(1300), CGFloat(500))
        pinky2.position = CGPointMake(CGFloat(200), CGFloat(300))
        
        // Tests for pinky1 in scatter mode
        pinkyMovement1.scatterUpdate()
        XCTAssertEqual(pinky1.currentDir, Direction.Up, "Pinky scatter mode incorrectly change Blinky's direction")
        
        pinky1.changeDirection(.Down)
        pinkyMovement1.scatterUpdate()
        XCTAssertEqual(pinky1.currentDir, Direction.Down, "Pinky scatter mode incorrectly check update frame")

        pinky1.currentDir = .None
        pinky1.blocked.up = 1
        pinkyMovement1.scatterUpdate()
        XCTAssertEqual(pinky1.currentDir, Direction.Left, "Pinky scatter mode does not update when there are no paths")

        finishUpdateBuffer(pinkyMovement1, mode: GhostMovementMode.Scatter, buffer: 4)
        
        pinky1.currentDir = .Down
        pinkyMovement1.scatterUpdate()
        XCTAssertEqual(pinky1.currentDir, Direction.Left, "Pinky scatter mode incorrectly resume update frame")

        pinky1.blocked = (up: 1, down: 1, left: 1, right: 0)
        pinkyMovement1.scatterUpdate()
        XCTAssertEqual(pinky1.currentDir, Direction.Right, "Pinky scatter mode incorrectly reverse direction in dead end")

        
        // Tests for pinky2 in scatter mode
        pinkyMovement2.scatterUpdate()
        XCTAssertEqual(pinky2.currentDir, Direction.Up, "Pinky scatter mode incorrectly change Blinky's direction")

        pinky2.changeDirection(.Down)
        pinkyMovement2.scatterUpdate()
        XCTAssertEqual(pinky2.currentDir, Direction.Down, "Pinky scatter mode incorrectly check update frame")

        pacman1.position = CGPointMake(CGFloat(200), CGFloat(304))
        pinkyMovement2.scatterUpdate()
        XCTAssertEqual(pinky2.currentDir, Direction.Down, "Pinky scatter mode is affected by Pacman's position")
        
    }
    
    func testPinkyChaseMode() {
        let pinkyMovement1 = PinkyAIMovementControl(movableObject: pinky1)
        pinkyMovement1.dataSource = self
        let pinkyMovement2 = PinkyAIMovementControl(movableObject: pinky2)
        pinkyMovement2.dataSource = self

        pinky1.position = CGPointMake(CGFloat(1300), CGFloat(500))
        pinky2.position = CGPointMake(CGFloat(200), CGFloat(300))
        
        pacman1.position = CGPointMake(CGFloat(1308), CGFloat(500))
        pacman1.currentDir = Direction.Right
        pacman2.position = CGPointMake(CGFloat(1300), CGFloat(504))
        pacman2.currentDir = Direction.Up

        // Tests for pinky1 in chase mode
        pinkyMovement1.chaseUpdate()
        XCTAssertEqual(pinky1.currentDir, Direction.Up, "Pinky chase mode corrctly chase the nearest pacman")

        pinky1.changeDirection(Direction.Down)
        pinkyMovement1.chaseUpdate()
        XCTAssertEqual(pinky1.currentDir, Direction.Down, "Pinky chase mode incorrectly check update frame")

        finishUpdateBuffer(pinkyMovement1, mode: GhostMovementMode.Chase, buffer: 3)
        
        pinkyMovement1.chaseUpdate()
        XCTAssertNotEqual(pinky1.currentDir, Direction.Down, "Pinky chase mode incorrectly resume update frame")

        
        // Tests for pinky2 in chase mode
        pacman1.position = CGPointMake(CGFloat(212), CGFloat(290))
        pacman1.currentDir = Direction.Left
        
        pinkyMovement2.chaseUpdate()
        XCTAssertEqual(pinky2.currentDir, Direction.Down, "Pinky chase mode incorrectly change Blinky's direction")

        finishUpdateBuffer(pinkyMovement2, mode: GhostMovementMode.Scatter, buffer: 4)
        pinky2.blocked.down = 1
        pinkyMovement2.chaseUpdate()
        XCTAssertEqual(pinky2.currentDir, Direction.Left, "Pinky chase mode incorrectly chase nearest pacman")

        pinky2.blocked = (up: 1, down: 1, left: 1, right: 0)
        pinkyMovement2.chaseUpdate()
        XCTAssertEqual(pinky2.currentDir, Direction.Right, "Pinky chase mode incorrectly reverse direction in dead end")
    }
    
    func testInkyScatterMode() {
        let inkyMovement1 = InkyAIMovementControl(movableObject: inky1)
        inkyMovement1.dataSource = self
        let inkyMovement2 = InkyAIMovementControl(movableObject: inky2)
        inkyMovement2.dataSource = self
        
        inky1.position = CGPointMake(CGFloat(1300), CGFloat(500))
        inky2.position = CGPointMake(CGFloat(200), CGFloat(300))
        
        // Tests for inky1 in scatter mode
        inkyMovement1.scatterUpdate()
        XCTAssertEqual(inky1.currentDir, Direction.Down, "Inky scatter mode incorrectly change Blinky's direction")

        inky1.changeDirection(.Up)
        inkyMovement1.scatterUpdate()
        XCTAssertEqual(inky1.currentDir, Direction.Up, "Inky scatter mode incorrectly check update frame")

        finishUpdateBuffer(inkyMovement1, mode: GhostMovementMode.Scatter, buffer: 3)
        
        inky1.changeDirection(.Left)
        inkyMovement1.scatterUpdate()
        XCTAssertEqual(inky1.currentDir, Direction.Down, "Inky scatter mode incorrectly resume update frame")

        inky1.blocked = (up: 0, down: 1, left: 1, right: 1)
        inkyMovement1.scatterUpdate()
        XCTAssertEqual(inky1.currentDir, Direction.Up, "Inky scatter mode incorrectly reverse direction in dead end")

        
        // Tests for inky2 in scatter mode
        inkyMovement2.scatterUpdate()
        XCTAssertEqual(inky2.currentDir, Direction.Right, "Inky scatter mode incorrectly change Blinky's direction")

        inky2.changeDirection(.Down)
        inkyMovement2.scatterUpdate()
        XCTAssertEqual(inky2.currentDir, Direction.Right, "Inky scatter mode incorrectly check update frame")

        pacman1.position = CGPointMake(CGFloat(200), CGFloat(304))
        inkyMovement2.scatterUpdate()
        XCTAssertEqual(inky2.currentDir, Direction.Right, "Inky scatter mode is affected by Pacman's position")
    }
    
    func testInkyChaseMode() {
        let inkyMovement1 = InkyAIMovementControl(movableObject: inky1)
        inkyMovement1.dataSource = self
        let inkyMovement2 = InkyAIMovementControl(movableObject: inky2)
        inkyMovement2.dataSource = self
        
        inky1.position = CGPointMake(CGFloat(1300), CGFloat(500))
        inky2.position = CGPointMake(CGFloat(200), CGFloat(300))
        
        pacman1.position = CGPointMake(CGFloat(1290), CGFloat(512))
        pacman1.currentDir = Direction.Down
        blinky1.position = CGPointMake(CGFloat(1280), CGFloat(504))
        
        pacman2.position = CGPointMake(CGFloat(1316), CGFloat(450))
        pacman2.currentDir = Direction.Left
        blinky1.position = CGPointMake(CGFloat(1308), CGFloat(400))
        
        // Tests for inky1 in chase mode
        inkyMovement1.chaseUpdate()
        XCTAssertEqual(inky1.currentDir, Direction.Up, "Inky chase mode corrctly chase the nearest pacman")
        
        inky1.changeDirection(Direction.Down)
        inkyMovement1.chaseUpdate()
        XCTAssertEqual(inky1.currentDir, Direction.Down, "Inky chase mode incorrectly check update frame")

        finishUpdateBuffer(inkyMovement1, mode: GhostMovementMode.Chase, buffer: 3)
        
        inkyMovement1.chaseUpdate()
        XCTAssertNotEqual(inky1.currentDir, Direction.Down, "Inky chase mode incorrectly resume update frame")

        
        // Tests for inky2 in chase mode
        pacman1.position = CGPointMake(CGFloat(250), CGFloat(272))
        pacman1.currentDir = Direction.Up
        blinky1.position = CGPointMake(CGFloat(300), CGFloat(280))

        inkyMovement2.chaseUpdate()
        XCTAssertEqual(inky2.currentDir, Direction.Down, "Inky chase mode incorrectly change Blinky's direction")

        finishUpdateBuffer(inkyMovement2, mode: GhostMovementMode.Scatter, buffer: 4)
        inky2.blocked.down = 1
        inkyMovement2.chaseUpdate()
        XCTAssertEqual(inky2.currentDir, Direction.Left, "Inky chase mode incorrectly chase nearest pacman")

        inky2.blocked = (up: 1, down: 1, left: 1, right: 0)
        inkyMovement2.chaseUpdate()
        XCTAssertEqual(inky2.currentDir, Direction.Right, "Inky chase mode incorrectly reverse direction in dead end")
    }
    
    func testClydeScatterMode() {
        let clydeMovement1 = ClydeAIMovementControl(movableObject: clyde1)
        clydeMovement1.dataSource = self
        let clydeMovement2 = ClydeAIMovementControl(movableObject: clyde2)
        clydeMovement2.dataSource = self
        
        clyde1.position = CGPointMake(CGFloat(1300), CGFloat(500))
        clyde2.position = CGPointMake(CGFloat(200), CGFloat(300))

        // Tests for clyde1 in scatter mode
        clydeMovement1.scatterUpdate()
        XCTAssertEqual(clyde1.currentDir, Direction.Down, "Clyde scatter mode incorrectly change Blinky's direction")

        clyde1.changeDirection(.Up)
        clydeMovement1.scatterUpdate()
        XCTAssertEqual(clyde1.currentDir, Direction.Up, "Clyde scatter mode incorrectly check update frame")

        finishUpdateBuffer(clydeMovement1, mode: GhostMovementMode.Scatter, buffer: 3)
        
        clyde1.changeDirection(.Down)
        clydeMovement1.scatterUpdate()
        XCTAssertEqual(clyde1.currentDir, Direction.Left, "Clyde scatter mode incorrectly resume update frame")

        clyde1.blocked = (up: 1, down: 1, left: 1, right: 0)
        clydeMovement1.scatterUpdate()
        XCTAssertEqual(clyde1.currentDir, Direction.Right, "Clyde scatter mode incorrectly reverse direction in dead end")

        
        // Tests for clyde2 in scatter mode
        clydeMovement2.scatterUpdate()
        XCTAssertEqual(clyde2.currentDir, Direction.Down, "Clyde scatter mode incorrectly change Blinky's direction")
        
        clyde2.changeDirection(.Up)
        clydeMovement2.scatterUpdate()
        XCTAssertEqual(clyde2.currentDir, Direction.Up, "Clyde scatter mode incorrectly check update frame")

        pacman1.position = CGPointMake(CGFloat(204), CGFloat(300))
        clydeMovement2.scatterUpdate()
        XCTAssertEqual(clyde2.currentDir, Direction.Up, "Clyde scatter mode is affected by Pacman's position")
    }
    
    func testClydeChaseMode() {
        let clydeMovement1 = ClydeAIMovementControl(movableObject: clyde1)
        clydeMovement1.dataSource = self
        let clydeMovement2 = ClydeAIMovementControl(movableObject: clyde2)
        clydeMovement2.dataSource = self
        
        clyde1.position = CGPointMake(CGFloat(1300), CGFloat(500))
        clyde2.position = CGPointMake(CGFloat(200), CGFloat(300))
        
        pacman1.position = CGPointMake(CGFloat(1300), CGFloat(600))
        pacman2.position = CGPointMake(CGFloat(1700), CGFloat(500))
        
        // Tests for clyde1 in chase mode
        clydeMovement1.chaseUpdate()
        XCTAssertEqual(clyde1.currentDir, Direction.Up, "Clyde chase mode corrctly chase the nearest pacman")

        clyde1.changeDirection(Direction.Right)
        clydeMovement1.chaseUpdate()
        XCTAssertEqual(clyde1.currentDir, Direction.Right, "Clyde chase mode incorrectly check update frame")

        finishUpdateBuffer(clydeMovement1, mode: GhostMovementMode.Chase, buffer: 3)
        
        clydeMovement1.chaseUpdate()
        XCTAssertNotEqual(clyde1.currentDir, Direction.Right, "Clyde chase mode incorrectly resume update frame")

        
        // Tests for iclyde2 in chase mode
        pacman1.position = CGPointMake(CGFloat(200), CGFloat(305))

        clydeMovement2.chaseUpdate()
        XCTAssertEqual(clyde2.currentDir, Direction.Down, "Clyde chase mode incorrectly change Blinky's direction")

        finishUpdateBuffer(clydeMovement2, mode: GhostMovementMode.Scatter, buffer: 4)
        clyde2.blocked.down = 1
        clydeMovement2.chaseUpdate()
        XCTAssertEqual(clyde2.currentDir, Direction.Left, "Clyde chase mode incorrectly chase nearest pacman")

        clyde2.blocked = (up: 1, down: 1, left: 1, right: 0)
        clydeMovement2.chaseUpdate()
        XCTAssertEqual(clyde2.currentDir, Direction.Right, "Clyde chase mode incorrectly reverse direction in dead end")
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
