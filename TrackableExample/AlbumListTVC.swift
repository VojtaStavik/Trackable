//
//  AlbumListTVC.swift
//  Trackable
//
//  Created by Vojta Stavik on 20/12/15.
//  Copyright © 2015 STRV. All rights reserved.
//

import UIKit
import Trackable

class AlbumListTVC: UITableViewController {

    var albums : [Album]!

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = albums[indexPath.row].name
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        track(Events.User.didSelectAlbum)
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC = segue.destinationViewController as! AlbumDetailVC
        let selectedAlbum = albums[tableView.indexPathForSelectedRow!.row]
        
        destinationVC.title = selectedAlbum.name
        
        destinationVC.setupTrackableChain([Keys.previousVC ~>> "Album list"], parent: self)
    }
}

extension AlbumListTVC : TrackableClass {
    var trackedProperties : Set<TrackedProperty> {
        var selectedAlbum : Album?
        if let indexPath = tableView.indexPathForSelectedRow {
            selectedAlbum = albums[indexPath.row]
        }
        
        return [Keys.albumName ~>> selectedAlbum?.name ?? "none"]
    }
}