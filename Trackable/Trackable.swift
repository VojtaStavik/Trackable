//
//  Trackable.swift
//  Trackable
//
//  Created by Vojta Stavik on 06/12/15.
//  Copyright © 2015 STRV. All rights reserved.
//

import Foundation

/*
    Three levels of trackable properties:
    -----------------------------------------
    1. low - on the class level -> by implementing trackableProperties computed variable
    2. middle - on the instance level -> by calling addToTrackableProperties(properties, parent: Trackable?) on the instance
    3. high - on the event level -> by adding properties to trackEvent function

    Higher level property overrides lower level property with the same name.
*/

var trackEvent : ( (eventName: String, customInfo: [String: AnyObject]) -> Void )? = nil

public protocol Trackable {
    var trackedProperties: [TrackedProperty] { get }
}

// Default implementation of Trackable. We don't want to return nil
// as a default value, because we use internaly nil to identify released objects
public extension Trackable {
    var trackedProperties: [TrackedProperty] { return [] }
}


// -----------------------------
// Track event functions
public extension Trackable {
    public func track(event: Event, trackedProperties: [TrackedProperty]? = nil) {
        
    }
}