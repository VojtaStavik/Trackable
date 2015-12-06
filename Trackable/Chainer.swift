//
//  Chainer.swift
//  Trackable
//
//  Created by Vojta Stavik on 06/12/15.
//  Copyright © 2015 STRV. All rights reserved.
//

import Foundation

indirect enum ChainLink {
    case Tracker(instanceProperties: [TrackedProperty]?, classProperties: () -> [TrackedProperty]?)
    case Chainer(instanceProperties: [TrackedProperty]?, classProperties: () -> [TrackedProperty]? , parent: ChainLink?)
}

extension ChainLink {
    func track(event: Event, trackedProperties: [TrackedProperty]?) {
        switch self {
        case .Tracker(instanceProperties: let instanceProperties, classProperties: let classPropertiesClosure):
            
            break
        case .Chainer(instanceProperties: let instanceProperties, classProperties: let classPropertiesClosure, parent: let parent):
            break
        }
    }
}

extension ChainLink {
    static var responsibilityChainTable = [ObjectIdentifier : ChainLink]()
    
    /*
    Remove released objects from the chain table and returens removed chainers
    */
    static private func cleanupResponsibilityChainTable() -> [ChainLink] {
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