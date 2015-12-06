//
//  Property-Tests.swift
//  Trackable
//
//  Created by Vojta Stavik on 06/12/15.
//  Copyright © 2015 STRV. All rights reserved.
//

import Foundation
@testable import Trackable
import Quick
import Nimble

class PropertyTests : QuickSpec {

    enum TestKeys : String, Key {
        case value1
        case value2
        case value3
    }

    override func spec() {
        describe("Set of properties") {
            context("updateValueFrom") {
                it("should add new value") {
                    var testSet = Set<TrackedProperty>([TestKeys.value1 ~>> "value1old" , TestKeys.value2 ~>> "value2old"])
                    let newValue = TestKeys.value3 ~>> "value3new"
                    
                    testSet.updateValuesFrom(Set<TrackedProperty>([newValue]))
                    
                    expect(testSet.count).to(equal(3))
                    expect(testSet.filter{ $0.key == TestKeys.value1.description }).toNot(beEmpty())
                    expect(testSet.filter{ $0.key == TestKeys.value2.description }).toNot(beEmpty())
                    expect(testSet.filter{ $0.key == TestKeys.value3.description }).toNot(beEmpty())
                    testSet.forEach {
                        switch $0.key {
                        case TestKeys.value1.description:
                            expect( $0.value as? String ).to(equal("value1old"))
                        case TestKeys.value2.description:
                            expect( $0.value as? String ).to(equal("value2old"))
                        case TestKeys.value3.description:
                            expect( $0.value as? String ).to(equal("value3new"))
                        default:
                            fail()
                        }
                    }
                }

                it("should update existing value") {
                    var testSet = Set<TrackedProperty>([TestKeys.value1 ~>> "value1old" , TestKeys.value2 ~>> "value2old"])
                    let newValue = TestKeys.value2 ~>> "value2new"
                    
                    testSet.updateValuesFrom(Set<TrackedProperty>([newValue]))
                    
                    expect(testSet.count).to(equal(2))
                    expect(testSet.filter{ $0.key == TestKeys.value1.description }).toNot(beEmpty())
                    expect(testSet.filter{ $0.key == TestKeys.value2.description }).toNot(beEmpty())
                    expect(testSet.filter{ $0.key == TestKeys.value3.description }).to(beEmpty())
                    testSet.forEach {
                        switch $0.key {
                        case TestKeys.value1.description:
                            expect( $0.value as? String ).to(equal("value1old"))
                        case TestKeys.value2.description:
                            expect( $0.value as? String ).to(equal("value2new"))
                        default:
                            fail()
                        }
                    }
                }

            }
        }
    }
}