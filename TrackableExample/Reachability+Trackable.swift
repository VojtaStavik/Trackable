//
//  Reachability+Trackable.swift
//  Trackable
//
//  Created by Vojta Stavik on 20/12/15.
//  Copyright © 2015 STRV. All rights reserved.
//

import Foundation
import Trackable

extension Reachability : TrackableClass {
    public var trackedProperties : Set<TrackedProperty> {
        return [Keys.reachabilityStatus ~>> currentReachabilityStatus.description]
    }
}
