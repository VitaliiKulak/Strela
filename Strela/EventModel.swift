//
//  EventModel.swift
//  Strela
//
//  Created by Vitalii Kulak on 11/15/17.
//  Copyright © 2017 Vitalii Kulak. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

class Event  {
    
    let addedByUserUid: String
    let eventName: String
    let eventDate: Date
    let ageToEvent : String
    let gender: String
    let eventComment: String
    let eventImageUrl: String
    var eventLocation : CLLocationCoordinate2D
    
    init(addedByUserUid: String,eventName: String,eventDate: Date,ageToEvent: String,gender: String,eventComment: String,eventLocation: CLLocationCoordinate2D, eventImageUrl: String) {
        self.addedByUserUid = addedByUserUid
        self.eventName = eventName
        self.ageToEvent = ageToEvent
        self.gender = gender
        self.eventComment = eventComment
        self.eventImageUrl = eventImageUrl
        self.eventDate = eventDate
        self.eventLocation = eventLocation
          }
    
        
    init(snapshot: DataSnapshot) {
        
        
        let snapshotValue = snapshot.value as! [String: Any]
        
        addedByUserUid = snapshotValue["addedByUserUid"] as! String
        eventName = snapshotValue["eventName"] as! String
        ageToEvent = snapshotValue["ageToEvent"] as! String
        gender = snapshotValue["gender"] as! String
        eventComment = snapshotValue["eventComment"] as! String
        eventImageUrl = snapshotValue["eventImageUrl"] as!String
        let eventDateString = snapshotValue["eventDate"] as! String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
        eventDate = dateFormatter.date(from: eventDateString)!
        eventLocation = CLLocationCoordinate2D(latitude: snapshotValue["eventLatitude"] as! CLLocationDegrees, longitude: snapshotValue["eventLongitude"] as! CLLocationDegrees)
    }

}


