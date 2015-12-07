//
//  Event.swift
//  Trackable
//
//  Created by Vojta Stavik on 06/12/15.
//  Copyright © 2015 STRV. All rights reserved.
//

import Foundation

public protocol Event   : CustomStringConvertible { }

public extension Event where Self : RawRepresentable {
    public var description : String {
        return String(reflecting: self.dynamicType) + "." + "\(self.rawValue)"
    }
}
