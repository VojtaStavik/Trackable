//
//  Tools.swift
//  Trackable
//
//  Created by Vojta Stavik (vojtastavik.com) on 11/02/16.
//  Copyright © 2016 STRV. All rights reserved.
//

import Foundation

func inBackground(_ closure:  @escaping () -> Void) {
    DispatchQueue.global(qos: .default).async(execute: closure)
}
