//
//  Tools.swift
//  Trackable
//
//  Created by Vojta Stavik on 11/02/16.
//  Copyright © 2016 STRV. All rights reserved.
//

import Foundation

func inBackground(closure:  ()->()) {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), closure)
}

