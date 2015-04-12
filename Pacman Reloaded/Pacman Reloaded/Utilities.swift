//
//  Utilities.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 20/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation

let gameLevelIndexPathComparator = { (o1: AnyObject, o2: AnyObject) -> Bool in
    let first = o1 as NSIndexPath
    let second = o2 as NSIndexPath
    var result: Bool
    if first.section < second.section {
        result = true
    } else if first.section == second.section {
        result = first.row < second.row
    } else {
        result = false
    }
    return result
}

extension NSIndexPath {
    var previousRow: NSIndexPath {
        return NSIndexPath(forRow: self.row, inSection: self.section - 1)
    }
    
    var previousColumn: NSIndexPath {
        return NSIndexPath(forRow: self.row - 1, inSection: self.section)
    }
    
    var nextRow: NSIndexPath {
        return NSIndexPath(forRow: self.row, inSection: self.section + 1)
    }
    
    var nextColumn: NSIndexPath {
        return NSIndexPath(forRow: self.row + 1, inSection: self.section)
    }
}