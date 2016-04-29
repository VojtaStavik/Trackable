//
//  Property.swift
//  Trackable
//
//  Created by Vojta Stavik (vojtastavik.com) on 06/12/15.
//  Copyright © 2015 Vojta Stavik. All rights reserved.
//

import Foundation
/**
    Struct which encapsulates property Key and its value. It can be created using ~>> operator. 
    Example: let property = Key ~>> Value
 */
public struct TrackedProperty {
    public let key:     String
    public let value:   Any
    private init(key: Key, value: Any) {
        self.key = key.description
        self.value = value
    }
}


infix operator ~>> { associativity left }

public func ~>> (key: Key, value: String) -> TrackedProperty {
    return TrackedProperty(key: key, value: value)
}

public func ~>> (key: Key, value: Double) -> TrackedProperty {
    return TrackedProperty(key: key, value: value)
}

public func ~>> (key: Key, value: Int) -> TrackedProperty {
    return TrackedProperty(key: key, value: value)
}

public func ~>> (key: Key, value: Bool) -> TrackedProperty {
    return TrackedProperty(key: key, value: value)
}

public func ~>> (key: Key, value: Set<TrackedProperty>) -> TrackedProperty {
    return TrackedProperty(key: key, value: value)
}


extension TrackedProperty : Equatable { }
public func ==(l: TrackedProperty, r: TrackedProperty) -> Bool {
    return l.key == r.key
}

extension TrackedProperty : Hashable {
    public var hashValue : Int { return key.hash }
}

// Small "hack" how to constraint Set extension to a non-protocol type
public protocol TrackedPropertyProtocol { }
extension TrackedProperty : TrackedPropertyProtocol { }

public extension Set where Element : TrackedPropertyProtocol {
    public mutating func updateValuesFrom(properties: Set<TrackedProperty>) {
        var mutableSelf = self
        properties.flatMap { $0 as? Element}
                  .forEach { mutableSelf.insert($0) }
        self = mutableSelf
    }
    
    public var dictionaryRepresentation : [String : AnyObject] {
        return self.flattenSet
                   .reduce([String: AnyObject]()) { result, element in
                        var updatedResult = result
                        // we use flattenSet so we're sure that all values are AnyObject
                        updatedResult[element.key] = (element.value as! AnyObject)
                        return updatedResult
                    }
    }
    
    public var flattenSet : Set<TrackedProperty> {
        return reduce(Set<TrackedProperty>()) { (var result, property) -> Set<TrackedProperty> in
            let property = property as! TrackedProperty
            if let nestedSet = property.value as? Set<TrackedProperty> {
                for nestedProperty in nestedSet.flattenSet {
                    let key : Key = property.key
                    let nestedKey : Key = nestedProperty.key
                    result.insert(TrackedProperty(key: key.composeKeyWith(nestedKey), value: nestedProperty.value))
                }
            } else {
                result.insert(property)
            }
            return result
        }
    }
}

public func + (left: Set<TrackedProperty>, right: Set<TrackedProperty>) -> Set<TrackedProperty> {
    var newLeft = left
    newLeft.updateValuesFrom(right)
    return newLeft
}

public func += (inout left: Set<TrackedProperty>, right: Set<TrackedProperty>) {
    left = left + right
}
