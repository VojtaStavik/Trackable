//
//  Trackable.swift
//  Trackable
//
//  Created by Vojta Stavik on 06/12/15.
//  Copyright © 2015 STRV. All rights reserved.
//

import Foundation

/**
This function is called for the actual event tracking to remote service. Send data to servers here.
*/
var trackEvent : ( (eventName: String, customInfo: [String: AnyObject]) -> Void )? = nil


/*
    Three levels of trackable properties:
    -----------------------------------------
    1. low - on the class level -> by implementing trackableProperties computed variable
    2. middle - on the instance level -> by calling addToTrackableProperties(properties, parent: Trackable?) on the instance
    3. high - on the event level -> by adding properties to trackEvent function

    Higher level property overrides lower level property with the same name.
*/


public protocol Trackable : class {
    var trackedProperties: Set<TrackedProperty> { get }
}

// Default implementation of Trackable. We don't want to return nil
// as a default value, because we use nil internaly to identify released objects
public extension Trackable {
    var trackedProperties: Set<TrackedProperty> { return [] }
}


// -----------------------------
// Track event functions
public extension Trackable {
    public func track(event: Event, trackedProperties: Set<TrackedProperty>? = nil) {
        // update properties
        var properties = self.trackedProperties
        if let eventProperties = trackedProperties {
            properties.updateValuesFrom(eventProperties)
        }
        
        if let ownLink = ChainLink.responsibilityChainTable[uniqueIdentifier] {
            ownLink.track(event, trackedProperties: properties)
        } else {
            // we don't have own link in the chain. Just track the event
            trackEvent?(eventName: event.description, customInfo: properties.dictionaryRepresentation)
        }
    }
}


// -----------------------------
// Setup functions
public extension Trackable {
    public func setupTrackableChain(trackedProperties: Set<TrackedProperty>, parrent: Trackable?) {
        let parentLink: ChainLink

        if let
            identifier = parrent?.uniqueIdentifier,
            link = ChainLink.responsibilityChainTable[identifier]
        {
            parentLink = link
        } else {
            parentLink = ChainLink.Tracker(instanceProperties: [], classProperties: { return [] })
        }

        let newLink = ChainLink.Chainer(instanceProperties: trackedProperties, classProperties: { [weak self] in self?.trackedProperties }, parent: parentLink)
        ChainLink.responsibilityChainTable[self.uniqueIdentifier] = newLink
    }
}

extension Trackable {
    var uniqueIdentifier : ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}
