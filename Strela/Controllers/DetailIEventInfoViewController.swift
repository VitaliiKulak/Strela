//
//  DetailIEventInfoViewController.swift
//  Strela
//
//  Created by Vitalii Kulak on 12/22/17.
//  Copyright © 2017 Vitalii Kulak. All rights reserved.
//

import UIKit


class DetailIEventInfoViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var creatorNumber: UILabel!
    @IBOutlet weak var careatorAge: UILabel!
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var ageToEventLabel: UILabel!
    @IBOutlet weak var eventGender: UILabel!
    @IBOutlet weak var eventComment: UITextView!
    
    //MARK: - Properties
    var event: Event?
    let formatter = DateFormatter()
    //MARK: - ViewConfig
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCreatorInfo()
        eventName.text = event?.eventName
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let eventDateString =  formatter.string(from: (event?.eventDate)!)
        eventDateLabel.text = eventDateString
        if let urlString = event?.eventImageUrl {
            RequestManager.shared.getImage(url: urlString, completionHandler: { [weak self] (image) in
                if let strongSelf = self {
                    strongSelf.eventImage.image = image
                }
            })
        }
        eventGender.text = "Gender: \(event!.gender)"
        eventComment.text = event?.eventComment
        ageToEventLabel.text = "Age: \(event!.ageToEvent)"
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK: - Methods
    
    func fetchCreatorInfo() {
        if let userUid = event?.addedByUserUid {
            UserManager.shared.getUser(userUid: userUid, completionHandler: { [weak self] (user) in
                if let strongSelf = self {
                    strongSelf.creatorNameLabel.text = "Name: \(user.userName)"
                    strongSelf.creatorNumber.text = "Phone: \(user.phoneNumber)"
                    strongSelf.formatter.dateFormat = "yyyy"
                    let birthdayDateString =  strongSelf.formatter.string(from: user.birthday)
                    let creatorAge = String(2018 - Int(birthdayDateString)!)
                    strongSelf.careatorAge.text = "Age: \(creatorAge)"
                    
                    let userImageUrl = user.profileImageURL
                    RequestManager.shared.getImage(url: userImageUrl, completionHandler: { [weak self] (image) in
                        if let strongSelf = self {
                            strongSelf.userImage.image = image
                        }
                    })
                }
            })
        }
    }
}

