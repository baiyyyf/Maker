//
//  Maker.swift
//  Maker
//
//  Created by byyyf on 2/27/16.
//  Copyright © 2016 byyyf. All rights reserved.
//

import Foundation

private let StringType  = "String"
private let IntType     = "Int"
private let FloatType   = "Float"
private let DoubleType  = "Double"
private let BoolType    = "Bool"

public class Maker: NSObject, NSCoding {
 
    required public override init() {
        super.init()
    }
    
    //MARK: - NSCoding
    required public init?(coder aDecoder: NSCoder) {
        super.init()
        let ignoredKeys = ignoreKeysForEncoding()
        let mirror = Mirror(reflecting: self)
        
        func f(mirror: Mirror) {
            for case let (key?, _) in mirror.children {
                if let unvaildKeys = ignoredKeys where unvaildKeys.contains(key) {
                    return
                }
                let value = aDecoder.decodeObjectForKey(key)
                self.setValue(value, forKey: key)
            }
        }
        f(mirror)
        if let superMirror = mirror.superclassMirror() {
            f(superMirror)
        }
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        let ignoredKeys = ignoreKeysForEncoding()
        let mirror = Mirror(reflecting: self)
        func f(mirror: Mirror) {
            for case let (key?, value) in mirror.children {
                if let unvaildKeys = ignoredKeys where unvaildKeys.contains(key) {
                    return
                }
                aCoder.encodeObject(value as? AnyObject, forKey: key)
            }
        }
        f(mirror)
        if let superMirror = mirror.superclassMirror() {
            f(superMirror)
        }
    }
    
    public func keyToMappedKey() -> [String: String]? {
        return nil
    }
    
    public func customConvert(obj: AnyObject?) { }
    
    public func ignoreKeysForEncoding() -> [String]? {
        return nil
    }
    
    public class func printTransformedKeyMap(JSON: AnyObject, transform: String -> String? = transformClourse) -> [String: String] {
        guard let JSON = JSON as? NSDictionary else {
            return [:]
        }
        var dict = [String: String]()
        for case let key as String in JSON.allKeys {
            if let tmp = transform(key) {
                dict[tmp] = key
            }
        }
        print(dict)
        return dict
    }
    
    private static var transformClourse: String -> String? {
        return { str in
            var tmp = [Character]()
            var hasUnderline = false
            for var ch in str.characters {
                if (hasUnderline) {
                    ch = String(ch).uppercaseString.characters.first!
                    hasUnderline = false
                }
                if (ch == "_") {
                    hasUnderline = true
                    continue
                }
                tmp.append(ch)
            }
            let result = String(tmp)
            if (result == str) {
                return nil
            }
            return result
        }
    }
    
    public class func objectFromJSON(JSON: AnyObject) -> Self {
        let object = self.init()
        
        let objectMirror = Mirror(reflecting: object)
        let keyMap = object.keyToMappedKey()
        let objectType = "\(objectMirror.subjectType)"
        
        func f(mirror: Mirror) {
            for case let (key?, value) in mirror.children {
                
                let mappedKey = keyMap?[key] ?? key
                
                let propertyMirror = Mirror(reflecting: value)
                
                guard var propertyValue = (JSON[mappedKey].map { $0 }) else {
                    /**
                    #if DEBUG
                        print("\(object): Skipd [\(mappedKey)]")
                    #endif
                    */
                    continue
                }
                
                let propertyTypeString = "\(propertyMirror.subjectType)"
                
                func parseInternalType(type: String) {
                    var strictPropertyValue: AnyObject?
                    let isArray = propertyValue is NSArray
                    switch type {
                    case StringType:
                        strictPropertyValue = isArray ? propertyValue as! [String] : propertyValue as? String
                    case IntType:
                        strictPropertyValue = isArray ? propertyValue as! [Int] : propertyValue as? Int
                    case BoolType:
                        strictPropertyValue = isArray ? propertyValue as! [Bool] : propertyValue as? Bool
                    case DoubleType:
                        strictPropertyValue = isArray ? propertyValue as! [Double] : propertyValue as? Double
                    case FloatType:
                        strictPropertyValue = isArray ? propertyValue as! [Float] : propertyValue as? Float
                    default:
                        break
                    }
                    if let value = strictPropertyValue {
                        object.setValue(value, forKey: key)
                    }
                }
                
                func parseDictionary(valueTypeName: String) {
                    var strictPropertyValue: AnyObject?
                    let isArray = propertyValue is NSArray
                    switch valueTypeName {
                    case StringType:
                        strictPropertyValue = isArray ? (propertyValue as! NSArray).map { $0 as! [String: String] } : propertyValue as? [String: String]
                    case IntType:
                        strictPropertyValue = isArray ? (propertyValue as! NSArray).map { $0 as! [String: Int] } : propertyValue as? [String: Int]
                    case BoolType:
                        strictPropertyValue = isArray ? (propertyValue as! NSArray).map { $0 as! [String: Bool] } : propertyValue as? [String: Bool]
                    case DoubleType:
                        strictPropertyValue = isArray ? (propertyValue as! NSArray).map { $0 as! [String: Double] } : propertyValue as? [String: Double]
                    case FloatType:
                        strictPropertyValue = isArray ? (propertyValue as! NSArray).map { $0 as! [String: Float] } : propertyValue as? [String: Float]
                    default:
                        break
                    }
                    if let value = strictPropertyValue {
                        object.setValue(value, forKey: key)
                    }
                }
                
                func parseObject(name: String) -> Bool {
                    if let objectClass = MKClassFromString(name) as? Maker.Type {
                        let sel = objectClass.objectFromJSON
                        if let arrayValue = propertyValue as? NSArray {
                            propertyValue = arrayValue.map(sel)
                        } else {
                            propertyValue = sel(propertyValue)
                        }
                        object.setValue(propertyValue, forKey: key)
                        return true
                    }
                    return false
                }
                
                func parse(name: String?, mirror: Mirror?) {
                    if let name = name {
                        let isObject = parseObject(name)
                        if !isObject && name.hasPrefix("Array") {
                            let internalTypeName = name.dropPair(5)
                            parse(internalTypeName, mirror: nil)
                        } else if name.hasPrefix("Dictionary"), let valueTypeName = valueTypeNameForDictionary(name) {
                            parseDictionary(valueTypeName)
                        }
                    } else if let propertyDisplayStyle = propertyMirror.displayStyle {
                        switch propertyDisplayStyle {
                        case .Class:
                            parseObject(propertyTypeString)
                        case .Collection:
                            parse(propertyTypeString, mirror: nil)
                        case .Optional:
                            let internalTypeName = propertyTypeString.dropPair(8)
                            parse(internalTypeName, mirror: nil)
                        case .Dictionary:
                            if let valueTypeName = valueTypeNameForDictionary(propertyTypeString) {
                                parseDictionary(valueTypeName)
                            }
                        default:
                            break
                        }
                    } else {
                        parseInternalType(propertyTypeString)
                    }
                }
                parse(nil, mirror: propertyMirror)
            }
        }
        
        f(objectMirror)
        if let superMirror = objectMirror.superclassMirror() {
            f(superMirror)
        }
        
        object.customConvert(JSON)
        return object
    }
}

private let projectIdentifier = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName").stringValue

private func MKClassFromString(className: String) -> AnyClass? {
    let classStringName = "_TtC\(projectIdentifier.utf16.count)\(projectIdentifier)\(className.utf16.count)\(className)"
    return NSClassFromString(classStringName)
}

private func valueTypeNameForDictionary(name: String) -> String? {
    if var str = name.dropPair(10).split(",").last {
        str.removeAtIndex(str.startIndex)
        return str
    }
    return nil
}