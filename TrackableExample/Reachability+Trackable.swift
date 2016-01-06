//
//  Reachability+Trackable.swift
//  Trackable
//
//  Created by Vojta Stavik on 20/12/15.
//  Copyright © 2015 STRV. All rights reserved.
//

import Foundation
import Trackable

// Do you need to include data from 3rd party classes?  Just make a TrackableClass extension and return them in trackedProperties!

extension Reachability : TrackableClass {
    public var trackedProperties : Set<TrackedProperty> {
        return [Keys.App.reachabilityStatus ~>> currentReachabilityStatus.description]
    }
}
