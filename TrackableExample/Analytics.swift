//
//  Analytics.swift
//  Trackable
//
//  Created by Vojta Stavik on 20/12/15.
//  Copyright © 2015 STRV. All rights reserved.
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

        setupTrackableChain()
    }
    
    func trackEventToMixpanel(eventName: String, trackedProperties: [String: AnyObject]) {
        // we want to print arguments in alphabetical order
        let listOfArguments = trackedProperties.sort({ $0.0 < $1.0 }).reduce("") { (finalString, element) -> String in
            return finalString + "   -\(element.0):  \(element.1)\n"
        }
        print("\n---------------------------- \nEvent: \(eventName)\n\(listOfArguments)--------------")
        
        mixpanel.track(eventName, properties: trackedProperties)
    }
}

extension Analytics : TrackableClass {
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
}

enum Keys : String, Key {
    case beatleName
    case albumName
    case userLikesAlbum
    case previousVC
    
    enum App : String, Key {
        case uptime
        case reachabilityStatus
    }
}