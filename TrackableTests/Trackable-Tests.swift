//
//  Trackable-Tests.swift
//  Trackable
//
//  Created by Vojta Stavik (vojtastavik.com) on 07/12/15.
//  Copyright © 2015 Vojta Stavik. All rights reserved.
//

import Foundation
@testable import Trackable
import Quick
import Nimble

class TrackableTests : QuickSpec {
    
    enum TestEvents : String, Event {
        case Event1
    }
    
    enum TestKeys : String, Key {
        enum Tests : String, Key {
            case test1
            case test2
        }
        case test1
    }
    
    override func spec() {
        beforeEach {
            trackEventToRemoteServiceClosure = nil
            keyPrefixToRemove = nil
            eventPrefixToRemove = nil
            
            ChainLink.responsibilityChainTable = [ObjectIdentifier : ChainLink]()
        }

        describe("Trackable") {
            it("object returns exmpty set by default") {
                class TestClass : TrackableClass { }
                let testClass = TestClass()
                expect(testClass.trackedProperties.isEmpty).to(beTrue())
            }

            describe("track") {
                it("should track event") {
                    class TestClass : TrackableClass {}
                    let testClass = TestClass()
                    
                    var receivedEventName: String?
                    var receivedProperties: [String: AnyObject]?
                    
                    trackEventToRemoteServiceClosure = { (eventName: String, trackedProperties: [String: AnyObject]) in
                        receivedEventName = eventName
                        receivedProperties = trackedProperties
                    }
                    
                    testClass.track(TestEvents.Event1)
                    
                    expect(receivedEventName).to(equal(TestEvents.Event1.description))
                    expect(receivedProperties?.isEmpty).to(beTrue())
                }

                it("should track event properties") {
                    class TestClass : TrackableClass {}
                    let testClass = TestClass()
                    
                    var receivedEventName: String?
                    var receivedProperties: [String: AnyObject]?
                    
                    trackEventToRemoteServiceClosure = { (eventName: String, trackedProperties: [String: AnyObject]) in
                        receivedEventName = eventName
                        receivedProperties = trackedProperties
                    }
                    
                    testClass.track(TestEvents.Event1, trackedProperties: [TestKeys.test1 ~>> "Hello", TestKeys.Tests.test2 ~>> true])
                    
                    expect(receivedEventName).to(equal(TestEvents.Event1.description))
                    expect(receivedProperties?[TestKeys.test1.description] as? String).to(equal("Hello"))
                    expect(receivedProperties?[TestKeys.Tests.test2.description] as? Bool).to(beTrue())
                }

                it("should append class properties to track event properties") {
                    class TestClass : TrackableClass {
                        var trackedProperties : Set<TrackedProperty> {
                            return [TestKeys.test1 ~>> "Hello"]
                        }
                    }
                    let testClass = TestClass()
                    
                    var receivedEventName: String?
                    var receivedProperties: [String: AnyObject]?
                    
                    trackEventToRemoteServiceClosure = { (eventName: String, trackedProperties: [String: AnyObject]) in
                        receivedEventName = eventName
                        receivedProperties = trackedProperties
                    }
                    
                    testClass.track(TestEvents.Event1, trackedProperties: [TestKeys.Tests.test2 ~>> "World"])
                    
                    expect(receivedEventName).to(equal(TestEvents.Event1.description))
                    expect(receivedProperties?[TestKeys.test1.description] as? String).to(equal("Hello"))
                    expect(receivedProperties?[TestKeys.Tests.test2.description] as? String).to(equal("World"))
                }

                it("should append instance properties to track event properties") {
                    class TestClass : TrackableClass { }
                    let testClass = TestClass()

                    var receivedEventName: String?
                    var receivedProperties: [String: AnyObject]?
                    
                    trackEventToRemoteServiceClosure = { (eventName: String, trackedProperties: [String: AnyObject]) in
                        receivedEventName = eventName
                        receivedProperties = trackedProperties
                    }
                    
                    testClass.setupTrackableChain(trackedProperties: [TestKeys.test1 ~>> "Hello"], parent: nil)
                    testClass.track(TestEvents.Event1, trackedProperties: [TestKeys.Tests.test2 ~>> "World"])
                    
                    expect(receivedEventName).to(equal(TestEvents.Event1.description))
                    expect(receivedProperties?[TestKeys.test1.description] as? String).to(equal("Hello"))
                    expect(receivedProperties?[TestKeys.Tests.test2.description] as? String).to(equal("World"))
                }
                
                context("when run from background thread") {
                    it("should track event") {
                        class TestClass : TrackableClass {}
                        let testClass = TestClass()
                        
                        var receivedEventName: String?
                        var receivedProperties: [String: AnyObject]?
                        
                        trackEventToRemoteServiceClosure = { (eventName: String, trackedProperties: [String: AnyObject]) in
                            receivedEventName = eventName
                            receivedProperties = trackedProperties
                        }
                        
                        inBackground {
                            testClass.track(TestEvents.Event1)
                        }
                        
                        expect(receivedEventName).toEventually(equal(TestEvents.Event1.description))
                        expect(receivedProperties?.isEmpty).toEventually(beTrue())
                    }
                    
                    it("should track event properties") {
                        class TestClass : TrackableClass {}
                        let testClass = TestClass()
                        
                        var receivedEventName: String?
                        var receivedProperties: [String: AnyObject]?
                        
                        trackEventToRemoteServiceClosure = { (eventName: String, trackedProperties: [String: AnyObject]) in
                            receivedEventName = eventName
                            receivedProperties = trackedProperties
                        }
                        
                        inBackground {
                            testClass.track(TestEvents.Event1, trackedProperties: [TestKeys.test1 ~>> "Hello", TestKeys.Tests.test2 ~>> true])
                        }
                        
                        expect(receivedEventName).toEventually(equal(TestEvents.Event1.description))
                        expect(receivedProperties?[TestKeys.test1.description] as? String).toEventually(equal("Hello"))
                        expect(receivedProperties?[TestKeys.Tests.test2.description] as? Bool).toEventually(beTrue())
                    }
                    
                    it("should append class properties to track event properties") {
                        class TestClass : TrackableClass {
                            var trackedProperties : Set<TrackedProperty> {
                                return [TestKeys.test1 ~>> "Hello"]
                            }
                        }
                        let testClass = TestClass()
                        
                        var receivedEventName: String?
                        var receivedProperties: [String: AnyObject]?
                        
                        trackEventToRemoteServiceClosure = { (eventName: String, trackedProperties: [String: AnyObject]) in
                            receivedEventName = eventName
                            receivedProperties = trackedProperties
                        }
                        
                        inBackground {
                            testClass.track(TestEvents.Event1, trackedProperties: [TestKeys.Tests.test2 ~>> "World"])
                        }
                        
                        expect(receivedEventName).toEventually(equal(TestEvents.Event1.description))
                        expect(receivedProperties?[TestKeys.test1.description] as? String).toEventually(equal("Hello"))
                        expect(receivedProperties?[TestKeys.Tests.test2.description] as? String).toEventually(equal("World"))
                    }
                    
                    it("should append instance properties to track event properties") {
                        class TestClass : TrackableClass { }
                        let testClass = TestClass()
                        
                        var receivedEventName: String?
                        var receivedProperties: [String: AnyObject]?
                        
                        trackEventToRemoteServiceClosure = { (eventName: String, trackedProperties: [String: AnyObject]) in
                            receivedEventName = eventName
                            receivedProperties = trackedProperties
                        }
                        
                        inBackground {
                            testClass.setupTrackableChain(trackedProperties: [TestKeys.test1 ~>> "Hello"], parent: nil)
                            testClass.track(TestEvents.Event1, trackedProperties: [TestKeys.Tests.test2 ~>> "World"])
                        }
                        
                        expect(receivedEventName).toEventually(equal(TestEvents.Event1.description))
                        expect(receivedProperties?[TestKeys.test1.description] as? String).toEventually(equal("Hello"))
                        expect(receivedProperties?[TestKeys.Tests.test2.description] as? String).toEventually(equal("World"))
                    }
                }
            }
            
            describe("instance properties") {
                it("should override class properties") {
                    class TestClass : TrackableClass {
                        var trackedProperties : Set<TrackedProperty> {
                            return [TestKeys.test1 ~>> "Hello"]
                        }
                    }
                    let testClass = TestClass()
                    
                    var receivedEventName: String?
                    var receivedProperties: [String: AnyObject]?
                    
                    trackEventToRemoteServiceClosure = { (eventName: String, trackedProperties: [String: AnyObject]) in
                        receivedEventName = eventName
                        receivedProperties = trackedProperties
                    }
                    
                    testClass.setupTrackableChain(trackedProperties: [TestKeys.test1 ~>> "World"], parent: nil)
                    testClass.track(TestEvents.Event1)
                    
                    expect(receivedEventName).to(equal(TestEvents.Event1.description))
                    expect(receivedProperties?[TestKeys.test1.description] as? String).to(equal("World"))
                }
                
                context("when run from background thread") {
                    it("should override class properties") {
                        class TestClass : TrackableClass {
                            var trackedProperties : Set<TrackedProperty> {
                                return [TestKeys.test1 ~>> "Hello"]
                            }
                        }
                        let testClass = TestClass()
                        
                        var receivedEventName: String?
                        var receivedProperties: [String: AnyObject]?
                        
                        trackEventToRemoteServiceClosure = { (eventName: String, trackedProperties: [String: AnyObject]) in
                            receivedEventName = eventName
                            receivedProperties = trackedProperties
                        }
                        
                        inBackground {
                            testClass.setupTrackableChain(trackedProperties: [TestKeys.test1 ~>> "World"], parent: nil)
                            testClass.track(TestEvents.Event1)
                        }
                        
                        expect(receivedEventName).toEventually(equal(TestEvents.Event1.description))
                        expect(receivedProperties?[TestKeys.test1.description] as? String).toEventually(equal("World"))
                    }
                }
            }

            describe("event properties") {
                it("should override class and instance properties") {
                    class TestClass : TrackableClass {
                        var trackedProperties : Set<TrackedProperty> {
                            return [TestKeys.test1 ~>> "Hello"]
                        }
                    }
                    let testClass = TestClass()
                    
                    var receivedEventName: String?
                    var receivedProperties: [String: AnyObject]?
                    
                    trackEventToRemoteServiceClosure = { (eventName: String, trackedProperties: [String: AnyObject]) in
                        receivedEventName = eventName
                        receivedProperties = trackedProperties
                    }
                    
                    testClass.setupTrackableChain(trackedProperties: [TestKeys.test1 ~>> "World"], parent: nil)
                    testClass.track(TestEvents.Event1, trackedProperties: [TestKeys.test1 ~>> "Finally"])
                    
                    expect(receivedEventName).to(equal(TestEvents.Event1.description))
                    expect(receivedProperties?[TestKeys.test1.description] as? String).to(equal("Finally"))
                }
                
                context("when run from background thread") {
                    it("should override class and instance properties") {
                        class TestClass : TrackableClass {
                            var trackedProperties : Set<TrackedProperty> {
                                return [TestKeys.test1 ~>> "Hello"]
                            }
                        }
                        let testClass = TestClass()
                        
                        var receivedEventName: String?
                        var receivedProperties: [String: AnyObject]?
                        
                        trackEventToRemoteServiceClosure = { (eventName: String, trackedProperties: [String: AnyObject]) in
                            receivedEventName = eventName
                            receivedProperties = trackedProperties
                        }
                        
                        inBackground {
                            testClass.setupTrackableChain(trackedProperties: [TestKeys.test1 ~>> "World"], parent: nil)
                            testClass.track(TestEvents.Event1, trackedProperties: [TestKeys.test1 ~>> "Finally"])
                        }
                        
                        expect(receivedEventName).toEventually(equal(TestEvents.Event1.description))
                        expect(receivedProperties?[TestKeys.test1.description] as? String).toEventually(equal("Finally"))
                    }
                }
            }

            describe("tracked properties of all types") {
                it("should be tracked") {
                    class TestClass : TrackableClass {
                        var trackedProperties : Set<TrackedProperty> {
                            return [TestKeys.test1 ~>> "Hello"]
                        }
                    }
                    let testClass = TestClass()
                    
                    var receivedEventName: String?
                    var receivedProperties: [String: AnyObject]?
                    
                    trackEventToRemoteServiceClosure = { (eventName: String, trackedProperties: [String: AnyObject]) in
                        receivedEventName = eventName
                        receivedProperties = trackedProperties
                    }
                    
                    testClass.setupTrackableChain(trackedProperties: [TestKeys.Tests.test1 ~>> "World"], parent: nil)
                    testClass.track(TestEvents.Event1, trackedProperties: [TestKeys.Tests.test2 ~>> "Finally"])
                    
                    expect(receivedEventName).to(equal(TestEvents.Event1.description))
                    expect(receivedProperties?[TestKeys.test1.description] as? String).to(equal("Hello"))
                    expect(receivedProperties?[TestKeys.Tests.test1.description] as? String).to(equal("World"))
                    expect(receivedProperties?[TestKeys.Tests.test2.description] as? String).to(equal("Finally"))
                }
                
                it("should override parent's properties for the same keys") {
                    class TestClassParent : TrackableClass {
                        var trackedProperties : Set<TrackedProperty> {
                            return [TestKeys.test1 ~>> "ParentHello"]
                        }
                    }
                    
                    class TestClass : TrackableClass {
                        var trackedProperties : Set<TrackedProperty> {
                            return [TestKeys.test1 ~>> "Hello"]
                        }
                    }

                    let testClass = TestClass()
                    let testClassParent = TestClassParent()
                    
                    testClass.setupTrackableChain(trackedProperties: [TestKeys.Tests.test1 ~>> "World"], parent: nil)
                    testClassParent.setupTrackableChain(trackedProperties: [TestKeys.Tests.test1 ~>> "ParentWorld"], parent: testClass)

                    var receivedEventName: String?
                    var receivedProperties: [String: AnyObject]?
                    
                    trackEventToRemoteServiceClosure = { (eventName: String, trackedProperties: [String: AnyObject]) in
                        receivedEventName = eventName
                        receivedProperties = trackedProperties
                    }
                    
                    testClass.track(TestEvents.Event1)
                    
                    expect(receivedEventName).to(equal(TestEvents.Event1.description))
                    expect(receivedProperties?[TestKeys.test1.description] as? String).to(equal("Hello"))
                    expect(receivedProperties?[TestKeys.Tests.test1.description] as? String).to(equal("World"))
                }
                
                context("when run from background thread") {
                    it("should be tracked") {
                        class TestClass : TrackableClass {
                            var trackedProperties : Set<TrackedProperty> {
                                return [TestKeys.test1 ~>> "Hello"]
                            }
                        }
                        let testClass = TestClass()
                        
                        var receivedEventName: String?
                        var receivedProperties: [String: AnyObject]?
                        
                        trackEventToRemoteServiceClosure = { (eventName: String, trackedProperties: [String: AnyObject]) in
                            receivedEventName = eventName
                            receivedProperties = trackedProperties
                        }
                        
                        inBackground {
                            testClass.setupTrackableChain(trackedProperties: [TestKeys.Tests.test1 ~>> "World"], parent: nil)
                            testClass.track(TestEvents.Event1, trackedProperties: [TestKeys.Tests.test2 ~>> "Finally"])
                        }
                        
                        expect(receivedEventName).toEventually(equal(TestEvents.Event1.description))
                        expect(receivedProperties?[TestKeys.test1.description] as? String).toEventually(equal("Hello"))
                        expect(receivedProperties?[TestKeys.Tests.test1.description] as? String).toEventually(equal("World"))
                        expect(receivedProperties?[TestKeys.Tests.test2.description] as? String).toEventually(equal("Finally"))
                    }
                    
                    it("should override parent's properties for the same keys") {
                        class TestClassParent : TrackableClass {
                            var trackedProperties : Set<TrackedProperty> {
                                return [TestKeys.test1 ~>> "ParentHello"]
                            }
                        }
                        
                        class TestClass : TrackableClass {
                            var trackedProperties : Set<TrackedProperty> {
                                return [TestKeys.test1 ~>> "Hello"]
                            }
                        }
                        
                        let testClass = TestClass()
                        let testClassParent = TestClassParent()
                        
                        testClass.setupTrackableChain(trackedProperties: [TestKeys.Tests.test1 ~>> "World"], parent: nil)
                        testClassParent.setupTrackableChain(trackedProperties: [TestKeys.Tests.test1 ~>> "ParentWorld"], parent: testClass)
                        
                        var receivedEventName: String?
                        var receivedProperties: [String: AnyObject]?
                        
                        trackEventToRemoteServiceClosure = { (eventName: String, trackedProperties: [String: AnyObject]) in
                            receivedEventName = eventName
                            receivedProperties = trackedProperties
                        }
                        
                        inBackground {
                            testClass.track(TestEvents.Event1)
                        }
                        
                        expect(receivedEventName).toEventually(equal(TestEvents.Event1.description))
                        expect(receivedProperties?[TestKeys.test1.description] as? String).toEventually(equal("Hello"))
                        expect(receivedProperties?[TestKeys.Tests.test1.description] as? String).toEventually(equal("World"))
                    }
                }
            }
            
            describe("setupTrackableChain") {
                context("when parent link is nil") {
                    it("creates chain link properly") {
                        class TestClass : TrackableClass {
                            var trackedProperties : Set<TrackedProperty> {
                                return [TestKeys.test1 ~>> "test1" ,TestKeys.Tests.test2 ~>> true]
                            }
                        }
                        
                        let testClass = TestClass()
                        testClass.setupTrackableChain(trackedProperties: [TestKeys.Tests.test1 ~>> 5], parent: nil)
                        
                        let link = ChainLink.responsibilityChainTable[testClass.uniqueIdentifier]!
                        
                        if case .Chainer(instanceProperties: let instanceProperties, classProperties: let classPropertiesClosure , parent: let parrentLink) = link {
                            expect(parrentLink).to(beNil())
                            expect(instanceProperties.count).to(equal(1))
                            expect(classPropertiesClosure()?.count).to(equal(2))
                        } else {
                            fail()
                        }
                    }
                    
                    context("when run from background thread") {
                        it("creates chain link properly") {
                            class TestClass : TrackableClass {
                                var trackedProperties : Set<TrackedProperty> {
                                    return [TestKeys.test1 ~>> "test1" ,TestKeys.Tests.test2 ~>> true]
                                }
                            }
                            
                            let testClass = TestClass()
                            inBackground {
                                testClass.setupTrackableChain(trackedProperties: [TestKeys.Tests.test1 ~>> 5], parent: nil)
                            }
                            
                            var linkData: (instanceProperties: Set<TrackedProperty>?, classPropertiesClosure: () -> Set<TrackedProperty>? , parent: ChainLink?) {
                                guard let link = ChainLink.responsibilityChainTable[testClass.uniqueIdentifier] else {
                                    return (nil, { return nil }, nil)
                                }
                                if case .Chainer(instanceProperties: let instanceProperties, classProperties: let classPropertiesClosure , parent: let parentLink) = link {
                                    return (instanceProperties, classPropertiesClosure, parentLink)
                                }
                                return (nil, { return nil }, nil)
                            }
                            
                            expect(linkData.parent).toEventually(beNil())
                            expect(linkData.instanceProperties?.count).toEventually(equal(1))
                            expect(linkData.classPropertiesClosure()?.count).toEventually(equal(2))
                        }
                    }
                }
                
                context("with parent link") {
                    it("creates chain link properly") {
                        class TestClass : TrackableClass {
                            var trackedProperties : Set<TrackedProperty> {
                                return [TestKeys.test1 ~>> "test1" ,TestKeys.Tests.test2 ~>> true]
                            }
                        }
                        
                        class TestClass2 : TrackableClass {
                            var trackedProperties : Set<TrackedProperty> {
                                return [TestKeys.test1 ~>> true]
                            }
                        }
                        
                        let testClass = TestClass()
                        testClass.setupTrackableChain(trackedProperties: [TestKeys.Tests.test1 ~>> 5], parent: nil)
                        
                        let testClass2 = TestClass2()
                        testClass.setupTrackableChain(trackedProperties: [], parent: testClass2)
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
                    
                    context("when run from background thread") {
                        it("creates chain link properly") {
                            class TestClass : TrackableClass {
                                var trackedProperties : Set<TrackedProperty> {
                                    return [TestKeys.test1 ~>> "test1" ,TestKeys.Tests.test2 ~>> true]
                                }
                            }
                            
                            class TestClass2 : TrackableClass {
                                var trackedProperties : Set<TrackedProperty> {
                                    return [TestKeys.test1 ~>> true]
                                }
                            }
                            
                            let testClass = TestClass()
                            let testClass2 = TestClass2()
                            
                            inBackground {
                                testClass.setupTrackableChain(trackedProperties: [TestKeys.Tests.test1 ~>> 5], parent: nil)
                                testClass.setupTrackableChain(trackedProperties: [], parent: testClass2)
                            }
                            
                            var classPropertiesClosure: () -> Set<TrackedProperty>? {
                                guard let link = ChainLink.responsibilityChainTable[testClass.uniqueIdentifier] else {
                                    return { return nil }
                                }
                                if case .Chainer(instanceProperties: _, classProperties: _, parent: let parentLink) = link {
                                    guard let parentLink = parentLink else {
                                        return { return nil }
                                    }
                                    if case .Tracker(instanceProperties: _, classProperties: let classPropertiesClosure) = parentLink {
                                        return classPropertiesClosure
                                    }
                                }
                                return { return nil }
                            }
                            
                            expect(classPropertiesClosure()?.count).toEventually(equal(1))
                            expect(classPropertiesClosure()?.first?.value as? Bool).toEventually(equal(true))
                            expect(classPropertiesClosure()?.first?.key).toEventually(equal(TestKeys.test1.description))
                        }
                    }
                }
            }
        }
    }
}