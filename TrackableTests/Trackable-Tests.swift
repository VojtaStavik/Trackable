//
//  Trackable-Tests.swift
//  Trackable
//
//  Created by Vojta Stavik on 07/12/15.
//  Copyright © 2015 STRV. All rights reserved.
//

import Foundation
@testable import Trackable
import Quick
import Nimble

class TrackableTests : QuickSpec {
    
    enum TestKeys : String, Key {
        enum Tests : String, Key {
            case test1
            case test2
        }
        case test1
    }
    
    override func spec() {
        describe("Trackable") {
            it("object returns exmpty set by default") {
                class TestClass : Trackable { }
                let testClass = TestClass()
                expect(testClass.trackedProperties.isEmpty)
            }

            context("setupTrackableChain") {
                context("creates chain link properly") {
                    it("when parent link is nil") {
                        class TestClass : Trackable {
                            var trackedProperties : Set<TrackedProperty> {
                                return [TestKeys.test1 ~>> "test1" ,TestKeys.Tests.test2 ~>> true]
                            }
                        }
                        
                        let testClass = TestClass()
                        testClass.setupTrackableChain([TestKeys.Tests.test1 ~>> 5], parent: nil)
                        
                        let link = ChainLink.responsibilityChainTable[testClass.uniqueIdentifier]!
                        
                        if case .Chainer(instanceProperties: let instanceProperties, classProperties: let classPropertiesClosure , parent: let parrentLink) = link {
                            expect(parrentLink).to(beNil())
                            expect(instanceProperties.count).to(equal(1))
                            expect(classPropertiesClosure()?.count).to(equal(2))
                        } else {
                            fail()
                        }
                    }
                    
                    it("with parent link") {
                        class TestClass : Trackable {
                            var trackedProperties : Set<TrackedProperty> {
                                return [TestKeys.test1 ~>> "test1" ,TestKeys.Tests.test2 ~>> true]
                            }
                        }

                        class TestClass2 : Trackable {
                            var trackedProperties : Set<TrackedProperty> {
                                return [TestKeys.test1 ~>> true]
                            }
                        }
                        
                        let testClass = TestClass()
                        testClass.setupTrackableChain([TestKeys.Tests.test1 ~>> 5], parent: nil)

                        let testClass2 = TestClass2()
                        testClass.setupTrackableChain([], parent: testClass2)
                        let link = ChainLink.responsibilityChainTable[testClass.uniqueIdentifier]!
                        
                        if case .Chainer(instanceProperties: _ , classProperties: _ , parent: let parrentLink) = link {
                            if case ChainLink.Tracker(instanceProperties: _, classProperties: let classPropertiesClosure) = parrentLink! {
                                expect(classPropertiesClosure()?.count).to(equal(1))
                                expect(classPropertiesClosure()?.first?.value as? Bool).to(equal(true))
                                expect(classPropertiesClosure()?.first?.key).to(equal(TestKeys.test1.description))
                            } else {
                                fail()
                            }
                        } else {
                            fail()
                        }
                    }
                }
            }
        }
    }
}