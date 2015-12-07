//
//  Property.swift
//  Trackable
//
//  Created by Vojta Stavik on 06/12/15.
//  Copyright © 2015 STRV. All rights reserved.
//

import Foundation

public struct TrackedProperty {
    public let key:     String
    public let value:   AnyObject
    private init(key: Key, value: AnyObject) {
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

public func ~>> (key: Key, value: [String : AnyObject]) -> TrackedProperty {
    return TrackedProperty(key: key, value: value)
}


extension TrackedProperty : Equatable { }
public func ==(l: TrackedProperty, r: TrackedProperty) -> Bool {
    return l.key == r.key
}

extension TrackedProperty : Hashable {
    public var hashValue : Int { return key.hash }
}

extension Set {
    mutating func updateValuesFrom(properties: Set<TrackedProperty>) {
        var mutableSelf = self
        properties.flatMap { $0 as? Element}
                  .forEach { mutableSelf.insert($0) }
        self = mutableSelf
    }
    
    var dictionaryRepresentation : [String : AnyObject] {
        return self.flatMap { $0 as? TrackedProperty }
                   .reduce([String: AnyObject]()) { result, element in
                        var updatedResult = result
                        updatedResult[element.key] = element.value
                        return updatedResult
                    }
    }
}
