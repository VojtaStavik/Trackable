//
//  Key-Tests.swift
//  Trackable
//
//  Created by Vojta Stavik on 06/12/15.
//  Copyright © 2015 STRV. All rights reserved.
//

import Foundation
@testable import Trackable
import Quick
import Nimble

enum Beatles : String, Key {
    case John
    enum Info : String, Key {
        case Age
    }
}

enum John: String, Key {
    case Age
}

class KeyTests : QuickSpec {

    enum TestKeys : String, Key {
        enum Tests : String, Key {
            case test1
            case test2
        }
        case test1
    }
    
    override func spec() {
        beforeEach {
            keyPrefixToRemove = nil
            eventPrefixToRemove = nil
            smartKeyComposingEnabled = true
        }
        
        describe("Key") {
            context("description") {
                it("should be generated based on namespace structure") {
                    expect(TestKeys.Tests.test1.description).to(equal("TrackableTests.KeyTests.TestKeys.Tests.test1"))
                    expect(TestKeys.Tests.test2.description).to(equal("TrackableTests.KeyTests.TestKeys.Tests.test2"))
                    expect(TestKeys.test1.description).to(equal("TrackableTests.KeyTests.TestKeys.test1"))
                }
            }
        }
        
        describe("composeKeyWith") {
            
            let key1 = Beatles.John
            let key2 = Beatles.Info.Age
            let key3 = TestKeys.Tests.test1
            
            context("when smartKeyComposingEnabled is enabled") {
                beforeEach {
                    smartKeyComposingEnabled = true
                }

                it("should merge key descriptions") {
                    expect(key1.composeKeyWith(key2)).to(equal("TrackableTests.Beatles.John.Info.Age"))
                    expect(key1.composeKeyWith(key3)).to(equal("TrackableTests.Beatles.John.KeyTests.TestKeys.Tests.test1"))
                }

                it("should remove repeating elements from key descriptions") {
                    expect(key1.composeKeyWith(key2)).to(equal("TrackableTests.Beatles.John.Info.Age"))
                }
            }

            context("when smartKeyComposingEnabled is disabled") {
                beforeEach {
                    smartKeyComposingEnabled = false
                }
                
                it("should not merge key descriptions") {
                    expect(key1.composeKeyWith(key2)).to(equal("TrackableTests.Beatles.John.TrackableTests.Beatles.Info.Age"))
                }
                
                it("should not remove repeating elements from key descriptions") {
                    expect(key1.composeKeyWith(key2)).to(equal("TrackableTests.Beatles.John.TrackableTests.Beatles.Info.Age"))
                }
            }
        }
        
        describe("keyPrefixToRemove") {
            context("when presented") {
                beforeEach {
                    keyPrefixToRemove = "TrackableTests."
                }
                
                afterEach {
                    keyPrefixToRemove = nil
                }
                
                it("should be removed from key description") {
                    let key1 = Beatles.John
                    let key2 = Beatles.Info.Age
                    let key3 = TestKeys.Tests.test1
                    expect(key1.composeKeyWith(key2)).to(equal("Beatles.John.Info.Age"))
                    expect(key1.composeKeyWith(key3)).to(equal("Beatles.John.KeyTests.TestKeys.Tests.test1"))
                }
            }
        }
    }
}