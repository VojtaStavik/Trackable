//
//  Trackable.swift
//  Trackable
//
//  Created by Vojta Stavik (vojtastavik.com) on 06/12/15.
//  Copyright © 2015 Vojta Stavik. All rights reserved.
//

import Foundation

/**
    This function is called for the actual event tracking to remote services. Send data to remote servers here.
    - parameter eventName: Event identifier
    - parameter trackedProperties: Event properties
*/
public var trackEventToRemoteServiceClosure : ( (_ eventName: String, _ trackedProperties: [String: AnyObject]) -> Void )? = nil

/*
    Three levels of trackable properties:
    -----------------------------------------
    3. high - on the event level -> by adding properties to trackEvent function
    2. middle - on the instance level -> by calling setupTrackableChain(properties, parent: Trackable?) on the instance
    1. low - on the class level -> by implementing trackableProperties computed variable

    Higher level property overrides lower level property with the same name.
*/

/**
    Conformance to this protocol allow a class to track events on *self*
*/
public protocol TrackableClass : class {
    var trackedProperties: Set<TrackedProperty> { get }
}

// Default implementation of Trackable. We don't want to return nil
// as a default value, because we use nil internaly to identify released objects
public extension TrackableClass {
    var trackedProperties: Set<TrackedProperty> { return [] }
}

// -----------------------------
// Track event functions
public extension TrackableClass {
    /**
        Track event on *self* with properties.
        - parameter event: Event identifier
        - parameter trackedProperties: Properties added to the event
     */
    public func track(_ event: Event, trackedProperties: Set<TrackedProperty>? = nil) {
        let trackClosure: () -> Void = {
            if let ownLink = ChainLink.responsibilityChainTable[self.uniqueIdentifier] {
                ownLink.track(event, trackedProperties: trackedProperties ?? [])
            } else {
                // we don't have own link in the chain. Just update properties and track the event
                var properties = self.trackedProperties
                if let eventProperties = trackedProperties {
                    properties.updateValuesFrom(eventProperties)
                }
                trackEventToRemoteServiceClosure?(event.description, properties.dictionaryRepresentation)
            }
        }
        
        if Thread.isMainThread {
            trackClosure()
        } else {
            DispatchQueue.main.async {
                trackClosure()
            }
        }

    }
}

// -----------------------------
// Setup functions
public extension TrackableClass {
    /**
        Setup *self* so it can be used as a part of a trackable chain.
        - parameter trackedProperties: Properties which will be added to all events tracked on self
        - parameter parent: Trackable parent for *self*. Events are not tracked directly but they are resend to parent.
     */
    public func setupTrackableChain(trackedProperties: Set<TrackedProperty> = [], parent: TrackableClass? = nil) {

        let setupClosure: () -> Void = {
            var parentLink: ChainLink? = nil
            
            if let identifier = parent?.uniqueIdentifier {
                if let link = ChainLink.responsibilityChainTable[identifier] {
                    // we have existing link for parent
                    parentLink = link
                } else {
                    // we create new link for paret
                    weak var weakParent = parent
                    parentLink = ChainLink.tracker(instanceProperties: [], classProperties: { weakParent?.trackedProperties })
                    ChainLink.responsibilityChainTable[identifier] = parentLink
                }
            }
            
            let newLink = ChainLink.chainer(instanceProperties: trackedProperties, classProperties: { [weak self] in self?.trackedProperties }, parent: parentLink)
            ChainLink.responsibilityChainTable[self.uniqueIdentifier] = newLink
        }
        
        if Thread.isMainThread {
            setupClosure()
        } else {
            DispatchQueue.main.async {
                setupClosure()
            }
        }
    }
}

extension TrackableClass {
    var uniqueIdentifier: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}
