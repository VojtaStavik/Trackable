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
    public init(key: Key, value: AnyObject) {
        self.key = key.description
        self.value = value
    }
}

//// Values which can be used in JSON
//public protocol TrackableValue : TrackedPropertyEvaluatable { }
//
//extension String :  TrackableValue { public var value : AnyObject { return self } }
//extension Int :     TrackableValue { public var value : AnyObject { return self } }
//extension Bool :    TrackableValue { public var value : AnyObject { return self } }
//extension Double :  TrackableValue { public var value : AnyObject { return self } }
//
//// Should we add dictionary as a trackable value, too?
//
//public protocol TrackedPropertyEvaluatable {
//    var value : AnyObject { get }
//}