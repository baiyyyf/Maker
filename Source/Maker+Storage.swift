//
//  Maker+Storage.swift
//  Maker
//
//  Created by byyyf on 2/27/16.
//  Copyright © 2016 byyyf. All rights reserved.
//

import Foundation

public extension Maker {
    public static func pathForDirectory(directory: NSSearchPathDirectory, name: String) -> String {
        let fileName = name.isEmpty ? Mirror(reflecting: self).description : name
        let folder = NSSearchPathForDirectoriesInDomains(directory, .UserDomainMask, true).last.stringValue
        return "\(folder)/\(fileName).mk"
    }
    
    public static func writeToFile(object: AnyObject, directory: NSSearchPathDirectory = .CachesDirectory, name: String) -> Bool {
        return NSKeyedArchiver.archiveRootObject(object, toFile: pathForDirectory(directory, name: name))
    }
    
    public func writeToFile(directory: NSSearchPathDirectory = .CachesDirectory, name: String) -> Bool {
        return Maker.writeToFile(self, directory: directory, name: name)
    }
    
    public static func delete(directory: NSSearchPathDirectory = .CachesDirectory, name: String) -> Bool {
        let manager = NSFileManager.defaultManager()
        let filePath = pathForDirectory(directory, name: name)
        if manager.fileExistsAtPath(filePath), let _ = try? manager.removeItemAtPath(filePath) {
            return true
        }
        return false
    }
    
    public func delete(directory: NSSearchPathDirectory = .CachesDirectory, name: String) -> Bool {
        return Maker.delete(directory, name: name)
    }
}