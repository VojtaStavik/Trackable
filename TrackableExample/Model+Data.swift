//
//  Model+Data.swift
//  Trackable
//
//  Created by Vojta Stavik (vojtastavik.com) on 20/12/15.
//  Copyright © 2015 Vojta Stavik. All rights reserved.
//

import Foundation

struct Beatle {
    let name : String
    let albums : [Album]
}

struct Album {
    let name : String
}

struct Beatles {
    func createTestData() -> [Beatle] {
        return [createJohn(), createPaul(), createGeorge(), createRingo()]
    }
    
    func createJohn() -> Beatle {
        return Beatle(name: "John", albums: [Album(name: "Imagine"), Album(name: "Double Fantasy")])
    }

    func createPaul() -> Beatle {
        return Beatle(name: "Paul", albums: [Album(name: "Band on the Run"), Album(name: "Driving Rain")])
    }

    func createGeorge() -> Beatle {
        return Beatle(name: "George", albums: [Album(name: "All Things Must Pass"), Album(name: "Brainwashed")])
    }

    func createRingo() -> Beatle {
        return Beatle(name: "Ringo", albums: [Album(name: "Ringo"), Album(name: "Y Not")])
    }
}