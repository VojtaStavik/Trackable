//
//  Key.swift
//  Trackable
//
//  Created by Vojta Stavik on 06/12/15.
//  Copyright © 2015 STRV. All rights reserved.
//

import Foundation

public protocol Key : CustomStringConvertible { }

/**
Specify a prefix which sould be removed from all keys. Usually you use this to remove project or module name.
*/
public var keyPrefixToRemove : String? = nil

public extension Key where Self : RawRepresentable {
    public var description : String {
        var rawDescription = String(reflecting: self.dynamicType) + "." + "\(self.rawValue)"
        if let
            prefixToRemove = keyPrefixToRemove,
            range = rawDescription.rangeOfString(prefixToRemove)
        {
            rawDescription.removeRange(range)
        }
        
        return rawDescription
    }
}

public extension Key {
    func composeKeyWith(key: Key) -> String {
        let myKey = description
        let otherKey = key.description
        
        var finalKey = myKey
        
        for i in 1...otherKey.characters.count {
            let prefix = String(otherKey.characters.prefix(i))
            if myKey.hasPrefix(prefix) == false {
                finalKey = finalKey + "." + String(otherKey.characters.suffix(otherKey.characters.count - i + 1))
                break
            }
        }
        
        return finalKey
    }
}

extension String : Key {
    public var description : String {
        return self
    }
}