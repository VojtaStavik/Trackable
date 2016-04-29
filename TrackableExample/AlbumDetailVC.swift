//
//  AlbumDetailVC.swift
//  Trackable
//
//  Created by Vojta Stavik (vojtastavik.com) on 20/12/15.
//  Copyright © 2015 Vojta Stavik. All rights reserved.
//

import UIKit
import Trackable

class AlbumDetailVC: UIViewController {

    var album : Album!

    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    @IBAction func didPressButton(sender: UIButton) {
        let userLikesAlbum = sender === yesButton
        track(Events.User.didRateAlbum, trackedProperties: [Keys.userLikesAlbum ~>> userLikesAlbum])
    }
}

extension AlbumDetailVC : TrackableClass { }