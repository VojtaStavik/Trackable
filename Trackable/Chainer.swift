//
//  Chainer.swift
//  Trackable
//
//  Created by Vojta Stavik on 06/12/15.
//  Copyright © 2015 STRV. All rights reserved.
//

import Foundation

indirect enum ChainLink {
    case Tracker(instanceProperties: Set<TrackedProperty>, classProperties: () -> Set<TrackedProperty>?)
    case Chainer(instanceProperties: Set<TrackedProperty>, classProperties: () -> Set<TrackedProperty>? , parent: ChainLink?)
}

extension ChainLink {
    func track(event: Event, trackedProperties: Set<TrackedProperty>) {
        switch self {
        case .Tracker(instanceProperties: let instanceProperties, classProperties: let classPropertiesClosure):
            var properties = classPropertiesClosure() ?? Set<TrackedProperty>()
            properties.updateValuesFrom(instanceProperties)
            properties.updateValuesFrom(trackedProperties)
            
            trackEventToRemoteServiceClosure?(eventName: event.description, trackedProperties: properties.dictionaryRepresentation)
            
        case .Chainer(instanceProperties: let instanceProperties, classProperties: let classPropertiesClosure, parent: let parent):
            var properties = classPropertiesClosure() ?? Set<TrackedProperty>()
            properties.updateValuesFrom(instanceProperties)
            properties.updateValuesFrom(trackedProperties)
            
            if let parent = parent {
                parent.track(event, trackedProperties: properties)
            } else {
                // parent was meanwhile released from memory, we just track the event
                trackEventToRemoteServiceClosure?(eventName: event.description, trackedProperties: properties.dictionaryRepresentation)
            }
        }
    }
}

extension ChainLink {
    static var responsibilityChainTable = [ObjectIdentifier : ChainLink]()
    
    /*
    Remove released objects from the chain table and returns removed chainers
    */
    static internal func cleanupResponsibilityChainTable() -> [ChainLink] {
        var deletedChainers : [ChainLink] = []
        
        for (key, value) in ChainLink.responsibilityChainTable {
            if case .Chainer(instanceProperties: _, classProperties: let classPropertiesClosure , parent: _) = value {
                if classPropertiesClosure() == nil {
                    // object is nil, we can delete his chainer
                    deletedChainers.append(ChainLink.responsibilityChainTable.removeValueForKey(key)!)
                }
            }

            if case .Tracker(instanceProperties: _, classProperties: let classPropertiesClosure) = value {
                if classPropertiesClosure() == nil {
                    // object is nil, we can delete his chainer
                    deletedChainers.append(ChainLink.responsibilityChainTable.removeValueForKey(key)!)
                }
            }
        }

        return deletedChainers
    }
}