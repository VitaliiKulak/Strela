//
//  MainViewController.swift
//  Strela
//
//  Created by Vitalii Kulak on 11/15/17.
//  Copyright © 2017 Vitalii Kulak. All rights reserved.
//
import UIKit
import GoogleMaps
import CoreLocation



class MapViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var mapView: GMSMapView!
    //MARK: - Properties
    var event: Event?
    var locationManager = CLLocationManager()
    private var infoWindow = MapMarkerWindow()
    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    weak var delegate: MapMarkerDelegate?
    let formatter = DateFormatter()
    
    //MARK: - ViewConfig
    override func viewDidLoad() {
        super.viewDidLoad()
        DatabaseService.shared.fetchEvents(mapView: self.mapView)
        self.mapView?.isMyLocationEnabled = true
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        mapView.delegate = self
        self.infoWindow = loadNiB()
        mapView.mapStyle(withFilename: "style", andType: "json")
        mapView.settings.myLocationButton = true
        
  }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK: - Methods
    func loadNiB() -> MapMarkerWindow {
        let infoWindow = MapMarkerWindow.instanceFromNib() as! MapMarkerWindow
        return infoWindow
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailEventSegue" {
            let eventDatailMap = segue.destination as! DetailIEventInfoViewController
            eventDatailMap.event = self.event
        }
    }
    //MARK: - IBAction
    @IBAction func SignOutAction(_ sender: Any) {
        DatabaseService.shared.SignOut()
        self.dismiss(animated: true, completion: nil)
    }
}


//MARK: - CLLocationDelegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 14.0)
        self.mapView?.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
    }
}


//MARK: - GMSMapViewDelegate

extension MapViewController : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        var markerData : Event?
        if let data = marker.userData! as? Event {
            markerData = data
        }
        locationMarker = marker
        infoWindow.removeFromSuperview()
        infoWindow = loadNiB()
        infoWindow.delegate = self
        guard let location = locationMarker?.position else {
            print("locationMarker is nil")
            return false
        }
        
        // Pass the spot data to the info window, and set its delegate to self
        infoWindow.eventData = markerData
         //Configure UI properties of info window
        infoWindow.alpha = 0.9
        infoWindow.layer.cornerRadius = 12
        infoWindow.layer.borderWidth = 2
        infoWindow.eventImage.layer.cornerRadius = 10
        infoWindow.infoButton.layer.cornerRadius = infoWindow.infoButton.frame.height / 2
        //Add data to infoWindow UI
        infoWindow.eventName.text = markerData?.eventName
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let eventDateString =  formatter.string(from: (markerData?.eventDate)!)
        infoWindow.eventDate.text = eventDateString
        if let eventImageUrl = markerData?.eventImageUrl {
            RequestManager.shared.getImage(url: eventImageUrl, completionHandler: { [weak self] (image) in
                if let strongSelf = self {
                    strongSelf.infoWindow.eventImage.image = image
                }
            })
        }
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate((markerData?.eventLocation)!) { (response, error) in
            if let adress = response?.firstResult() {
                self.infoWindow.eventAdress.text = adress.thoroughfare
            }
        }

        // Offset the info window to be directly above the tapped marker
        infoWindow.center = mapView.projection.point(for: location)
        infoWindow.center.y = infoWindow.center.y - 82
        self.view.addSubview(infoWindow)
        return false
    }
  
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if (locationMarker != nil){
            guard let location = locationMarker?.position else {
                print("locationMarker is nil")
                return
            }
            infoWindow.center = mapView.projection.point(for: location)
            infoWindow.center.y = infoWindow.center.y - 82
        }
    }
   
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
            }
}
//MARK: - MapMarkerDelegate
extension MapViewController: MapMarkerDelegate {
    func didTapInfoButton(data: Event) {
        self.event = data
        performSegue(withIdentifier: "detailEventSegue", sender: self)
    }
}
//MARK: - MapStyle
extension GMSMapView {
    func mapStyle(withFilename name: String, andType type: String) {
        do {
            if let styleURL = Bundle.main.url(forResource: name, withExtension: type) {
                self.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
}

