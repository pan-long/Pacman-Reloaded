//
//  GameLevelStorage.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 12/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit

class GameLevelStorage {
    
    class func getGameLevels() -> [String] {
        return getAllFiles()
    }
    
    class func getGameLevelImage(fileName: String) {
        
    }
    
}

extension GameLevelStorage { // For storing and loading new designs from/into dictionary
    
    class func storeGameLevelToFile(level: Dictionary<NSIndexPath, GameDesignType>, fileName: String) -> FileOpState {
        
        let indexPaths = level.keys.array.sorted(gameLevelIndexPathComparator)
        var doc: [Dictionary<String, String>] = []
        
        var pacmanID = 0
        var ghostID = 0
        
        for i in 0..<indexPaths.count {
            let indexPath = indexPaths[i]
            let row = Double(indexPath.section)
            let column = Double(indexPath.row)
            let gridWidth = Constants.GameScene.GridWidth
            let gridHeight = Constants.GameScene.GridHeight
            
            var dic = Dictionary<String, String>()
            if let typeName = level[indexPath]!.name {
                dic["type"] = typeName
                dic["x"] = Int((column + 0.5) * Double(gridWidth)).description
                dic["y"] = Int((row + 0.5) * Double(gridHeight)).description
                dic["width"] = Constants.GameScene.PacdotWidth.description
                dic["height"] = Constants.GameScene.PacdotWidth.description
                
                if level[indexPath]!.isPacman || level[indexPath]!.isGhost || typeName == "boundary" {
                    dic["width"] = Constants.GameScene.NormalWidth.description
                    dic["height"] = Constants.GameScene.NormalWidth.description
                    if level[indexPath]!.isPacman {
                        dic["id"] = pacmanID.description
                        pacmanID++
                    } else {
                        dic["id"] = ghostID.description
                        ghostID++
                    }
                }
            }
            
            doc.append(dic)
        }
        
        let fileSaved = addFile(fileName, contents: doc)
        println(getFilePath(fileName))
        return fileSaved ? .Success : .Failure
    }
    
    class func loadGameLevelFromFile(fileName: String) -> [Dictionary<String, String>]? {
        if let data = loadFile(fileName) {
            return (data as [Dictionary<String, String>])
        } else {
            return nil
        }
    }
}

// Lower level interactions with file system
extension GameLevelStorage {
    
    private class func getFilePath(fileName: String) -> String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        return documentDirectory.stringByAppendingPathComponent(fileName)
    }
    
    private class func getAllFiles() -> [String] {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let fileManager = NSFileManager.defaultManager()
        let directoryFiles = fileManager.contentsOfDirectoryAtPath(documentDirectory, error: nil) as [String]
        return directoryFiles
    }
    
    private class func fileExists(fileName: String) -> Bool {
        let fileManager = NSFileManager.defaultManager()
        let path = getFilePath(fileName)
        return fileManager.fileExistsAtPath(path)
    }
    
    private class func addFile(fileName: String, contents: NSArray) -> Bool {
        if fileExists(fileName) && !deleteFile(fileName) {
            return false
        }
        
        let path = getFilePath(fileName)
        return contents.writeToFile(path, atomically: true)
    }
    
    private class func deleteFile(fileName: String) -> Bool {
        if !fileExists(fileName) {
            return false
        }
        let fileManager = NSFileManager.defaultManager()
        let path = getFilePath(fileName)
        return fileManager.removeItemAtPath(path, error: nil)
    }
    
    private class func loadFile(fileName: String) -> NSArray? {
        if !fileExists(fileName) {
            return nil
        }
        let path = getFilePath(fileName)
        let data = NSArray(contentsOfFile: path)
        return data
    }
}