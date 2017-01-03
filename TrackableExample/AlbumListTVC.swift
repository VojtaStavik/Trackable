//
//  AlbumListTVC.swift
//  Trackable
//
//  Created by Vojta Stavik (vojtastavik.com) on 20/12/15.
//  Copyright © 2015 Vojta Stavik. All rights reserved.
//

import UIKit
import Trackable

class AlbumListTVC: UITableViewController {

    var albums: [Album]!

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = albums[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        track(Events.User.didSelectAlbum)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! AlbumDetailVC
        let selectedAlbum = albums[tableView.indexPathForSelectedRow!.row]
        
        destinationVC.title = selectedAlbum.name
        
        destinationVC.setupTrackableChain(trackedProperties: [Keys.previousVC ~>> "Album list"], parent: self)
    }
    
    var selectedAlbum: Album? {
        if let indexPath = tableView.indexPathForSelectedRow {
            return albums[indexPath.row]
        } else {
            return nil
        }
    }
}

extension AlbumListTVC : TrackableClass {
    var trackedProperties: Set<TrackedProperty> {
        return [Keys.albumName ~>> selectedAlbum?.name ?? "name"]
    }
}
