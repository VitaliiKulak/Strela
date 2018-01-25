//
//  EventDetailMapView.swift
//  Strela
//
//  Created by Vitalii Kulak on 12/20/17.
//  Copyright © 2017 Vitalii Kulak. All rights reserved.
//


import UIKit

protocol MapMarkerDelegate: class {
    func didTapInfoButton(data: Event)
}

class MapMarkerWindow: UIView {
    //MARK: - IBOutlet
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventAdress: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    //MARK: - Properties
    weak var delegate: MapMarkerDelegate?
    var eventData: Event?
    //MARK: - Methods
    @IBAction func didTapInfoButton(_ sender: UIButton) {
        delegate?.didTapInfoButton(data: eventData!)
    }
    
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MapMarkerWindowView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
}

