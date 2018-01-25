//
//  UserModel.swift
//  Strela
//
//  Created by Vitalii Kulak on 11/15/17.
//  Copyright © 2017 Vitalii Kulak. All rights reserved.
//

import Foundation
import Firebase

class User {
    
    let userUid: String
    let userName: String
    let email: String
    let birthday: Date
    let phoneNumber: String
    let gender: String
    let profileImageURL: String
    
    init(userUid: String,userName: String,email: String,phoneNumber: String,birthday: Date,gender: String,profileImageURL: String) {
        
        self.userUid = userUid
        self.userName = userName
        self.email = email
        self.gender = gender
        self.birthday = birthday
        self.profileImageURL = profileImageURL
        self.phoneNumber = phoneNumber
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: Any]
    
        
        userName = snapshotValue["userName"] as! String
        userUid = snapshotValue["userUid"] as! String
        email = snapshotValue["email"] as! String
        gender = snapshotValue["gender"] as! String
        profileImageURL = snapshotValue["profileImageURL"] as! String
        phoneNumber = snapshotValue["phoneNumber"] as! String
        let birthdayString = snapshotValue["birthday"] as! String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        birthday = dateFormatter.date(from: birthdayString)!
        
        
        }
    
}
