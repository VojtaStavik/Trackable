//
//  Chainer.swift
//  Trackable
//
//  Created by Vojta Stavik (vojtastavik.com) on 06/12/15.
//  Copyright © 2015 Vojta Stavik. All rights reserved.
//

import Foundation

indirect enum ChainLink {
    case tracker(instanceProperties: Set<TrackedProperty>, classProperties: () -> Set<TrackedProperty>?)
    case chainer(instanceProperties: Set<TrackedProperty>, classProperties: () -> Set<TrackedProperty>?, parent: ChainLink?)
}

extension ChainLink {
    func track(_ event: Event, trackedProperties: Set<TrackedProperty>) {
        switch self {
        case .tracker(instanceProperties: let instanceProperties, classProperties: let classPropertiesClosure):
            var properties = classPropertiesClosure() ?? Set<TrackedProperty>()
            properties.updateValuesFrom(instanceProperties)
            properties.updateValuesFrom(trackedProperties)
            
            trackEventToRemoteServiceClosure?(event.description, properties.dictionaryRepresentation)
            
        case .chainer(instanceProperties: let instanceProperties, classProperties: let classPropertiesClosure, parent: let parent):
            var properties = classPropertiesClosure() ?? Set<TrackedProperty>()
            properties.updateValuesFrom(instanceProperties)
            properties.updateValuesFrom(trackedProperties)
            
            if let parent = parent {
                parent.track(event, trackedProperties: properties)
            } else {
                // parent was meanwhile released from memory, we just track the event
                trackEventToRemoteServiceClosure?(event.description, properties.dictionaryRepresentation)
            }
        }
    }
}

extension ChainLink {
    static var responsibilityChainTable = [ObjectIdentifier: ChainLink]()
    
    /*
    Remove released objects from the chain table and returns removed chainers
    */
    @discardableResult static internal func cleanupResponsibilityChainTable() -> [ChainLink] {
        var deletedChainers: [ChainLink] = []
        
        for (key, value) in ChainLink.responsibilityChainTable {
            if case .chainer(instanceProperties: _, classProperties: let classPropertiesClosure, parent: _) = value {
                if classPropertiesClosure() == nil {
                    // object is nil, we can delete his chainer
                    deletedChainers.append(ChainLink.responsibilityChainTable.removeValue(forKey: key)!)
                }
            }

            if case .tracker(instanceProperties: _, classProperties: let classPropertiesClosure) = value {
                if classPropertiesClosure() == nil {
                    // object is nil, we can delete his chainer
                    deletedChainers.append(ChainLink.responsibilityChainTable.removeValue(forKey: key)!)
                }
            }
        }

        return deletedChainers
    }
}
