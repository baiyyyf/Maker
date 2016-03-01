//
//  Optional+ValueType.swift
//  Maker
//
//  Created by byyyf on 2/27/16.
//  Copyright © 2016 byyyf. All rights reserved.
//

import UIKit

public extension Optional {
    // Int
    var int: Int? {
        return self as? Int
    }
    
    var intValue: Int {
        return self as? Int ?? 0
    }
    
    // String
    var string: String? {
        return self as? String
    }
    
    var stringValue: String {
        return self as? String ?? ""
    }
    
    // Bool
    var bool: Bool? {
        return self as? Bool
    }
    
    var boolValue: Bool {
        return self as? Bool ?? false
    }
    
    // CGFloat
    var cgfloat: CGFloat? {
        return self as? CGFloat
    }
    
    var cgfloatValue: CGFloat {
        return self as? CGFloat ?? 0
    }
    
    // Array
    var array: NSArray? {
        return self as? NSArray
    }
    
    var arrayValue: NSArray {
        return self as? NSArray ?? []
    }
}