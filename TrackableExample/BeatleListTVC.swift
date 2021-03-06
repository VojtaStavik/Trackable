//
//  BeatleListTVC.swift
//  Trackable
//
//  Created by Vojta Stavik (vojtastavik.com) on 20/12/15.
//  Copyright © 2015 Vojta Stavik. All rights reserved.
//

import UIKit
import Trackable

class BeatleListTVC: UITableViewController {

    let beatles = Beatles().createTestData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTrackableChain(parent: analytics)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        track(Events.AlbumListVC.didAppear)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beatles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = beatles[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        track(Events.User.didSelectBeatle)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! AlbumListTVC
        let selectedBeatle = beatles[tableView.indexPathForSelectedRow!.row]
        
        destinationVC.title = selectedBeatle.name + "'s albums"
        destinationVC.albums = selectedBeatle.albums
        
        destinationVC.setupTrackableChain(trackedProperties: [Keys.previousVC ~>> "Beatle list"], parent: self)
    }
}

extension BeatleListTVC : TrackableClass {
    var trackedProperties: Set<TrackedProperty> {
        var selectedBeatle: Beatle?
        if let indexPath = tableView.indexPathForSelectedRow {
            selectedBeatle = beatles[indexPath.row]
        }
        return [Keys.beatleName ~>> selectedBeatle?.name ?? "none"]
    }
}
