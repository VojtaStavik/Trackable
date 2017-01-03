//
//  Event.swift
//  Trackable
//
//  Created by Vojta Stavik (vojtastavik.com) on 06/12/15.
//  Copyright © 2015 Vojta Stavik. All rights reserved.
//

import Foundation

public protocol Event: CustomStringConvertible { }

/**
    Specify a prefix which sould be removed from all event names. Usually you use this to remove project and/or module name.
*/
public var eventPrefixToRemove: String? = nil

public extension Event where Self : RawRepresentable {
    /**
        String representation of Event object.
     */
    public var description: String {
        var rawDescription = String(reflecting: type(of: self)) + "." + "\(self.rawValue)"
        if let
            prefixToRemove = eventPrefixToRemove,
            let range = rawDescription.range(of: prefixToRemove) {
            rawDescription.removeSubrange(range)
        }
        
        return rawDescription
    }
}
