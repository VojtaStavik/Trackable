# Trackable
[![Build Status](https://travis-ci.org/VojtaStavik/Trackable.svg?branch=master)](https://travis-ci.org/VojtaStavik/Trackable) [![codecov](https://codecov.io/gh/VojtaStavik/Trackable/branch/master/graph/badge.svg)](https://codecov.io/gh/VojtaStavik/Trackable) ![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)

**Trackable** is a simple analytics integration helper library. It’s especially designed for easy and comfortable integration with existing projects.

---

### Main features:
- [x] Easy integration to existing classes using extensions and protocols
- [x] Programmatically generated event and property identifiers
- [x] Smart tracking of properties by objects chaining *(if object “A” is set to be a parent of object “B”, event tracked on object “B” will also contain tracked properties from “A”)*

---

### Instalation

#### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate Trackable into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'Trackable'
```

Then, run the following command:

```bash
$ pod install
```

#### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate trackable into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "VojtaStavik/Trackable"
```

Run `carthage update` to build the framework and drag the built `Trackable.framework` into your Xcode project.

---

## Usage

Integration of the **Trackable** library is very easy and straightforward. See **example app** with complete implementation including all features.

### Events and Keys

Define events and keys using enums with ```String``` raw representation. These enums have to conform to ```Event``` or ```Key``` protocols. You can use nesting for better organization. String identifiers are created automatically, and they respect the complete enums structure. Example: ```Events.App.started``` will be translated to ```“<ModuleName>.Events.App.started”``` string.

```swift
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
    
    enum AlbumListVC : String, Event {
        case didAppear
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
```

### Tracking

You can track events on any class conforming to the ```TrackableClass``` protocol by calling ```self.track(event: Event)```. You can also call ```self.track(event: Event, trackedProperties: Set<TrackedProperty>)``` if you want to add some specific properties to the tracked event.

```TrackedProperty``` is a struct you can create using a custom infix operator ```~>>``` with ```Key``` and value. Allowed value types are ```String```, ```Double```, ```Int```, ```Bool``` and ```Set<TrackedProperty>```.

```swift
// Example:

import UIKit
import Trackable

class AlbumDetailVC: UIViewController {

    var album : Album!

    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    @IBAction func didPressButton(sender: UIButton) {
        let userLikesAlbum = (sender === yesButton)
        track(Events.User.didRateAlbum, trackedProperties: [Keys.userLikesAlbum ~>> userLikesAlbum])
    }
}

extension AlbumDetailVC : TrackableClass { }
```


### Tracked properties

**Trackable** is designed to allow you to easily track all properties you need. There are three levels where you can add custom data to tracked events. If you add a property with the same name, it will override the previous value with a lower level.

#### Level 3  
-	when calling track()function
-	properties on this level will be added only to the currently tracked event
-	**Typical usage:** When you want to track properties closely connected to the event.

```swift
// Example:
track(Events.User.didRateAlbum, trackedProperties: [Keys.userLikesAlbum ~>> userLikesAlbum])
```

#### Level 2
-	instance properties added by calling ```setupTrackableChain(trackedProperties:)``` on a ```TrackableClass``` instance.
-	these properties will be added to all events tracked on the object
-	**Typical usage:** When you want to set properties from the outside of the object (the object doesn’t know about them)

```swift
// Example:
import UIKit
import Trackable

class AlbumListTVC: UITableViewController {
	… code … 

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC = segue.destinationViewController as! AlbumDetailVC
        destinationVC.setupTrackableChain([Keys.previousVC ~>> "Album list"]) // all events tracked on destinationVC will have previousVC property included automatically
    }
}

extension AlbumListTVC : TrackableClass { }
```



#### Level 1
-	computed properties added by custom implementation of the ```TrackableClass``` protocol
-	these properties will be added to all events tracked on the object
-	**Typical usage:** When you want to add some set of properties to all events tracked on the object.

```swift
// Example:
class AlbumListTVC: UITableViewController {
    var albums : [Album]!

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        track(Events.User.didSelectAlbum) // selectedAlbum property will be added automatically
    }

    var selectedAlbum : Album? {
        if let indexPath = tableView.indexPathForSelectedRow {
            return albums[indexPath.row]
        } else {
            return nil
        }
    }
}

extension AlbumListTVC : TrackableClass {
    var trackedProperties : Set<TrackedProperty> {
        return [Keys.albumName ~>> selectedAlbum?.name ?? "none"]
    }
}
```

### Chaining
**The real advantage of Trackable comes with chaining.** You can set one object to be a Trackable parent of another object. If class A is a parent of class B, all events tracked on B will also automatically include ```trackedProperties``` from A.

```swift
// Example:
import UIKit
import Trackable

class AlbumListTVC: UITableViewController {

	… some code here … 

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC = segue.destinationViewController as! AlbumDetailVC
        destinationVC.setupTrackableChain([Keys.previousVC ~>> "Album list"], parent: self)
    }
    
    var selectedAlbum : Album? {
        if let indexPath = tableView.indexPathForSelectedRow {
            return albums[indexPath.row]
        } else {
            return nil
        }
    }
}

extension AlbumListTVC : TrackableClass {
    var trackedProperties : Set<TrackedProperty> {
        return [Keys.albumName ~>> selectedAlbum?.name ?? "none"]
    }
}

// All events tracked later on destinationVC will automatically have previousVC and albumName properties,
// without destinationVC even knowing those values exist!
```


### Connecting to Mixpanel (or any other service)
In order to perform the actual tracking into an analytics service, you have to provide an implementation for ```Trackable.trackEventToRemoteServiceClosure```.

```swift
// Example:
import Foundation
import Mixpanel
import Trackable

let analytics = Analytics() // singleton (yay!)

class Analytics {
    let mixpanel = Mixpanel.sharedInstanceWithToken("<token>")

    init() {
        Trackable.trackEventToRemoteServiceClosure = trackEventToMixpanel
        setupTrackableChain() // allows self to be part of the trackable chain
    }
    
    func trackEventToMixpanel(eventName: String, trackedProperties: [String: AnyObject]) {        
        mixpanel.track(eventName, properties: trackedProperties)
    }
}

extension Analytics : TrackableClass { }
```

Maybe you want to add some properties to all events tracked in your app. **It’s similar to Mixpanel super properties but with dynamic content!** You need to provide a custom implementation of the ```TrackableClass``` protocol:

```swift
extension Analytics : TrackableClass {
    var trackedProperties : Set<TrackedProperty> {
        return [Keys.App.uptime ~>> NSDate().timeIntervalSinceDate(startTime)]
    }
}
```
 and set the analytics object as a parent to all objects without a parent by calling ```setupTrackableChain(parent: analytics)``` on them:

```swift
// Example:
import UIKit
import Trackable

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        setupTrackableChain(parent: analytics)
        return true
    }

    func applicationDidBecomeActive(application: UIApplication) {
        track(Events.App.didBecomeActive)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        track(Events.App.didEnterBackground)
    }
    
    func applicationWillTerminate(application: UIApplication) {
        track(Events.App.terminated)
    }

}

extension AppDelegate : TrackableClass { }
```


## License

**Trackable** is released under the MIT license. See LICENSE for details.


--- 

*Readme inspired by [Alamofire](https://github.com/Alamofire/Alamofire)*. Thank you!
