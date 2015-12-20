//
//  Event.swift
//  Trackable
//
//  Created by Vojta Stavik on 06/12/15.
//  Copyright © 2015 STRV. All rights reserved.
//

import Foundation

public protocol Event : CustomStringConvertible { }

/**
Specify a prefix which sould be removed from all event names. Usually you use this to remove project or module name.
*/
public var eventPrefixToRemove : String? = nil

public extension Event where Self : RawRepresentable {
    public var description : String {
        var rawDescription = String(reflecting: self.dynamicType) + "." + "\(self.rawValue)"
        if let
            prefixToRemove = eventPrefixToRemove,
            range = rawDescription.rangeOfString(prefixToRemove)
        {
            rawDescription.removeRange(range)
        }
        
        return rawDescription
    }
}
