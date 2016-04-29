//
//  Analytics.swift
//  Trackable
//
//  Created by Vojta Stavik (vojtastavik.com) on 20/12/15.
//  Copyright © 2015 Vojta Stavik. All rights reserved.
//

import Foundation
import Mixpanel
import Trackable

let analytics = Analytics()

class Analytics {
    let startTime = NSDate()
    let mixpanel = Mixpanel.sharedInstanceWithToken("d48e6296949d6acab509dd3a00cc5cce")
    let reachability : Reachability?

    init() {
        reachability = try? Reachability.reachabilityForInternetConnection()
        
        Trackable.trackEventToRemoteServiceClosure = trackEventToMixpanel
        Trackable.eventPrefixToRemove = "TrackableExample.Events."
        Trackable.keyPrefixToRemove = "TrackableExample.Keys."

        setupTrackableChain() // allows self to be part of the trackable chain
    }
    
    func trackEventToMixpanel(eventName: String, trackedProperties: [String: AnyObject]) {
        mixpanel.track(eventName, properties: trackedProperties)
        
        // We want to also print the event and arguments to console.
        // (arguments will be in alphabetical order)
        let listOfArguments = trackedProperties.sort({ $0.0 < $1.0 }).reduce("") { (finalString, element) -> String in
            return finalString + "   -\(element.0):  \(element.1)\n"
        }
        print("\n---------------------------- \nEvent: \(eventName)\n\(listOfArguments)--------------")
    }
}

extension Analytics : TrackableClass {
    // Since the analytics object is a parent for all other TrackableClasses in the project,
    // these properties will be added to all events.
    // Notice the + operator. You can use it for merging sets of TrackedProperty: Set<TrackedProperty> + Set<TrackedProperty>
    var trackedProperties : Set<TrackedProperty> {
        return [Keys.App.uptime ~>> NSDate().timeIntervalSinceDate(startTime)]
                + (reachability?.trackedProperties ?? [Keys.App.reachabilityStatus ~>> "unknown"])
    }
}

enum Events {
    enum User : String, Event {
        case didSelectBeatle
        case didSelectAlbum
        case didRateAlbum
    }
    
    enum App : String, Event {
        case started
        case didBecomeActive
        case didEnterBackground
        case terminated
    }
    
    enum AlbumListVC : String, Event {
        case didAppear
    }
}

enum Keys : String, Key {
    case beatleName
    case albumName
    case userLikesAlbum
    case previousVC
    
    enum App : String, Key {
        case uptime
        case reachabilityStatus
        case launchTime
    }
}