//
//  DatabaseService.swift
//  Strela
//
//  Created by Vitalii Kulak on 11/13/17.
//  Copyright © 2017 Vitalii Kulak. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import GoogleMaps

class DatabaseService {
    
    static let shared = DatabaseService()
    private init() {}
    
    let usersReference = Database.database().reference().child("Users")
    let eventReference = Database.database().reference().child("Events")
    
    let storageReference = Storage.storage().reference()
    
    func fetchEvents(mapView: GMSMapView) {
        DatabaseService.shared.eventReference.observe(.value , with: { (snapshot) in
            for event in snapshot.children {
                let event =  Event(snapshot: event as! DataSnapshot)
                if event.eventDate > Date() {
                    DispatchQueue.main.async(execute: {
                        let marker = GMSMarker()
                        // Assign custom image for each marker
                        let markerImage = UIImage(named: "arrowred")
                        let markerView = UIImageView(image: markerImage)
                        // Customize color of marker here:
                        marker.iconView = markerView
                        marker.position = CLLocationCoordinate2D(latitude: event.eventLocation.latitude , longitude: event.eventLocation.longitude )
                        marker.map = mapView
                        // *IMPORTANT* Assign all the spots data to the marker's userData property
                        marker.userData = event
                    })
                }
            }
        })
    }
    func SignOut(){
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
}
