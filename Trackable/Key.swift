//
//  Key.swift
//  Trackable
//
//  Created by Vojta Stavik on 06/12/15.
//  Copyright © 2015 STRV. All rights reserved.
//

import Foundation

public protocol Key     : CustomStringConvertible { }

public extension Key where Self : RawRepresentable {
    public var description : String {
        return String(reflecting: self.dynamicType) + "." + "\(self.rawValue)"
    }
}