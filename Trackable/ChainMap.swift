//
//  ChainMap.swift
//  Trackable
//
//  Created by Vojta Stavik on 06/12/15.
//  Copyright © 2015 STRV. All rights reserved.
//

import Foundation

extension Trackable {
    static var responsibilityChainTable = [ObjectIdentifier : ChainLink]()
    
    /*
    Remove released objects from the chain table and returens removed chainers
    */
    static private func cleanupResponsibilityChainTable() -> [ChainLink] {
        var deletedChainers : [StatsChainer] = []
        for (key, value) in StatsChainer.responsibilityChainTable {
            if case .Chainer(customInfo: _, selfInfo: let selfInfoClosure, parent: _) = value {
                if selfInfoClosure() == nil {
                    // object is nil, we can delete his chainer
                    deletedChainers.append(StatsChainer.responsibilityChainTable.removeValueForKey(key)!)
                }
            }
        }
        print("Deleted chainers: \(deletedChainers)")
        return deletedChainers
    }

}