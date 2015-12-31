//
//  BeatleListTVC.swift
//  Trackable
//
//  Created by Vojta Stavik on 20/12/15.
//  Copyright © 2015 STRV. All rights reserved.
//

import UIKit
import Trackable

class BeatleListTVC: UITableViewController {

    let beatles = Beatles().createTestData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTrackableChain([], parent: analytics)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        track(Events.AlbumListVC.didAppear)
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beatles.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = beatles[indexPath.row].name
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        track(Events.User.didSelectBeatle)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC = segue.destinationViewController as! AlbumListTVC
        let selectedBeatle = beatles[tableView.indexPathForSelectedRow!.row]
        
        destinationVC.title = selectedBeatle.name + "'s albums"
        destinationVC.albums = selectedBeatle.albums
        
        destinationVC.setupTrackableChain([Keys.previousVC ~>> "Beatle list"], parent: self)
    }
}

extension BeatleListTVC : TrackableClass {
    var trackedProperties : Set<TrackedProperty> {
        var selectedBeatle : Beatle?
        if let indexPath = tableView.indexPathForSelectedRow {
            selectedBeatle = beatles[indexPath.row]
        }
        
        return [Keys.beatleName ~>> selectedBeatle?.name ?? "none"]
    }
}
