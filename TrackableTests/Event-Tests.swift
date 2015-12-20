//
//  Event-Tests.swift
//  Trackable
//
//  Created by Vojta Stavik on 20/12/15.
//  Copyright © 2015 STRV. All rights reserved.
//

import Foundation
@testable import Trackable
import Quick
import Nimble

enum BeatlesEvents : String, Event {
    case Concert
    enum Recordings : String, Event {
        case AbbeyRoad
    }
}

class EventTests : QuickSpec {
    override func spec() {
        beforeEach {
            beforeEach {
                keyPrefixToRemove = nil
                eventPrefixToRemove = nil
            }
        }
        
        describe("eventPrefixToRemove") {
            context("when presented") {
                it("should be removed from event description") {
                    eventPrefixToRemove = "TrackableTests."
                    let event1 = BeatlesEvents.Concert
                    let event2 = BeatlesEvents.Recordings.AbbeyRoad
                    expect(event1.description).to(equal("BeatlesEvents.Concert"))
                    expect(event2.description).to(equal("BeatlesEvents.Recordings.AbbeyRoad"))
                }
            }
        }
    }
}