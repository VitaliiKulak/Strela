//
//  UserManager.swift
//  Strela
//
//  Created by Vitalii Kulak on 1/14/18.
//  Copyright © 2018 Vitalii Kulak. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class UserManager {
    
    static let shared = UserManager()
    
    func getUser(userUid: String, completionHandler:@escaping (User) -> ()) {
        DatabaseService.shared.usersReference.child(userUid).observe(.value , with: { (snapshot) in
            completionHandler(User(snapshot: snapshot))
        })
    }
}
