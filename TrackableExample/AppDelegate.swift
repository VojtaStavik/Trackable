//
//  AppDelegate.swift
//  TrackableExample
//
//  Created by Vojta Stavik (vojtastavik.com) on 20/12/15.
//  Copyright © 2015 Vojta Stavik. All rights reserved.
//

import UIKit
import Trackable

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupTrackableChain(parent: analytics)
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        track(Events.App.didBecomeActive)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        track(Events.App.didEnterBackground)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        track(Events.App.terminated)
    }
}

extension AppDelegate : TrackableClass { }
