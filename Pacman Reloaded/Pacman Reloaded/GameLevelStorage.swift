//
//  GameLevelStorage.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 12/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit

class GameLevelStorage {
    
    class func getPredefinedGameLevels() -> [String] {
        // Four pre-installed game levels
        return ["CS3217", "level 0", "level 1", "level 2"]
    }
    
    class func getGameLevels() -> [String] {
        return getAllFiles().filter({ (str: String) -> Bool in
            return str.pathExtension == "xml"
        }).map({ (str: String) -> String in
            return str.stringByDeletingPathExtension
        })
    }
    
    class func getPredefinedGameLevelImage(fileName: String) -> UIImage? {
        let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "png")!
        let data = NSData(contentsOfFile: path)!
        return UIImage(data: data)
    }
    
    class func getGameLevelImage(fileName: String) -> UIImage? {
        let name = addPNGExtensionToFile(fileName)
        if !fileExists(name) {
            return nil
        }
        let path = getFilePath(name)
        let data = NSData(contentsOfFile: path)!
        let image = UIImage(data: data)
        return image
    }
    
    class func loadGameLevelFromPredefinedFile(fileName: String) -> [Dictionary<String, String>]? {
        let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "xml")!
        let data = NSArray(contentsOfFile: path)! as [Dictionary<String, String>]
        return data
    }
    
    class func loadGameLevelFromFile(fileName: String) -> [Dictionary<String, String>]? {
        if let data = loadFile(addXMLExtensionToFile(fileName)) {
            return (data as [Dictionary<String, String>])
        } else {
            return nil
        }
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
            let gridWidth = Constants.LevelDesign.DesignArea.GridWidth
            let gridHeight = Constants.LevelDesign.DesignArea.GridHeight
            let gameSceneHeight = Double(Constants.GameScene.Height)
            
            var dic = Dictionary<String, String>()
            if let typeName = level[indexPath]!.name {
                dic["type"] = typeName
                dic["x"] = Int((column + 0.5) * Double(gridWidth)).description
                dic["y"] = Int(gameSceneHeight - (row + 0.5) * Double(gridHeight)).description
                dic["width"] = Int(gridWidth).description
                dic["height"] = Int(gridHeight).description
                
                if level[indexPath]!.isPacman || level[indexPath]!.isGhost || typeName == "boundary" {
                    if level[indexPath]!.isPacman {
                        dic["id"] = pacmanID.description
                        pacmanID++
                    } else if level[indexPath]!.isGhost {
                        dic["id"] = ghostID.description
                        ghostID++
                    }
                } else if level[indexPath]!.isPacdot {
                    let ratio = CGFloat(Constants.GameScene.PacdotRatio)
                    dic["width"] = Int(gridWidth / ratio).description
                    dic["height"] = Int(gridHeight / ratio).description
                }
            }
            
            doc.append(dic)
        }
        
        let name = addXMLExtensionToFile(fileName)
        if fileExists(name) {
            deleteFile(name)
        }
        
        let fileSaved = addFile(name, contents: doc)
        return fileSaved ? .Success : .Failure
    }
    
    class func storeGameLevelImageToFile(image: UIImage, fileName: String) -> FileOpState {
        let imageData = UIImagePNGRepresentation(image)
        let name = addPNGExtensionToFile(fileName)
        if fileExists(name) {
            deleteFile(name)
        }
        let path = getFilePath(name)
        let fileSaved = imageData.writeToFile(path, atomically: true)
        return fileSaved ? .Success : .Failure
    }
}

// Lower level interactions with file system
extension GameLevelStorage {
    
    class func addXMLExtensionToFile(fileName: String) -> String {
        return fileName.stringByAppendingPathExtension("xml")!
    }
    
    class func addPNGExtensionToFile(fileName: String) -> String {
        return fileName.stringByAppendingPathExtension("png")!
    }
    
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