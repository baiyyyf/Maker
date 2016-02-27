//
//  String+Extension.swift
//  Maker
//
//  Created by byyyf on 2/27/16.
//  Copyright © 2016 byyyf. All rights reserved.
//

import Foundation

extension String {
    
    func dropPair(length: Int) -> String {
        let start = startIndex.advancedBy(length + 1)
        let end = endIndex.predecessor()
        return substringWithRange(start..<end)
    }
    
    func split (separator: Character) -> [String] {
        return self.characters.split { $0 == separator } .map { String($0) }
    }
}