//
//  CreateEventViewController.swift
//  Strela
//
//  Created by Vitalii Kulak on 11/15/17.
//  Copyright © 2017 Vitalii Kulak. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import WARangeSlider
import CoreLocation

class CreateEventViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var eventDataPicker: UIDatePicker!
    @IBOutlet weak var eventCommentTextField: UITextField!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var ageRangeLabel: UILabel!
    @IBOutlet weak var ageRangeSlider: RangeSlider!
    @IBOutlet weak var imageView: UIImageView!
    
    
    //MARK: - Properties
    var destination:GMSMarker = GMSMarker()
    let uid = Auth.auth().currentUser?.uid
    var locationManager = CLLocationManager()
    let imagePicker = UIImagePickerController()
    //MARK: - ViewConfig
    override func viewDidLoad() {
        super.viewDidLoad()
        eventDataPicker.minimumDate = Date()
        ageRangeSlider.addTarget(self, action: #selector(CreateEventViewController.rangeSliderValueChanged(_:)), for: .valueChanged)
        self.mapView?.isMyLocationEnabled = true
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        mapView.delegate = self
        mapView.mapStyle(withFilename: "style", andType: "json")
        mapView.settings.myLocationButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
//MARK: - Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    private func configurePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    private func configureView() {
        eventNameTextField.delegate = self
        eventCommentTextField.delegate = self
    }
    
    @objc func keyboardWillHide() {
        self.view.frame.origin.y = 0
    }
    
    @objc func keyboardWillChange(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if eventCommentTextField.isFirstResponder {
                self.view.frame.origin.y = -keyboardSize.height
            }
        }
    }
    //MARK: - IBActions
    
    @IBAction func addEventAction(_ sender: Any) {
        guard let eventName = eventNameTextField.text,
            eventName != "",
            let eventComment = eventCommentTextField.text,
            eventComment != ""
            else{
                AlertController.showAlert(self, title: "Missing Info", message: "Please fill out all fields")
                return
            }
        
        //Add Image
        
        let imageName = NSUUID().uuidString
        if let uploadData = UIImagePNGRepresentation(self.imageView.image!) {
            DatabaseService.shared.storageReference.child("eventImages").child("\(imageName).png").putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    return
                }
                if let eventImageUrl = metadata?.downloadURL()?.absoluteString {
                    // Format Date
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
                    let eventDateString =  formatter.string(from: self.eventDataPicker.date)
                    //Gender
                    var gender: String?
                    switch self.genderSegmentedControl.selectedSegmentIndex {
                    case 0: gender = "Male/Female"
                    case 1: gender = "Male"
                    case 2: gender = "Female"
                    default: break
                    }
                    //Slider
                    let ageToEventString = "\(Int(self.ageRangeSlider.lowerValue))-\(Int(self.ageRangeSlider.upperValue))"
                    
                    let eventParameters = ["eventName"      : self.eventNameTextField.text!,
                                           "addedByUserUid" : self.uid!,
                                           "eventComment"   : self.eventCommentTextField.text!,
                                           "gender"         : gender!,
                                           "eventLatitude"  : self.destination.position.latitude,
                                           "eventLongitude" : self.destination.position.longitude,
                                           "eventImageUrl"  : eventImageUrl,
                                           "ageToEvent"     : ageToEventString,
                                           "eventDate"      : eventDateString] as [String : Any]
                    
                    DatabaseService.shared.eventReference.childByAutoId().setValue(eventParameters)
                }
            })
        }
       _ = navigationController?.popViewController(animated: true)
    }
    @objc func rangeSliderValueChanged(_ ageRangeSlider: RangeSlider) {
        ageRangeLabel.text = "Age from: \(Int(ageRangeSlider.lowerValue))" + " " + "to: \(Int(ageRangeSlider.upperValue))"
    }
    @IBAction func choseUserPhotoAction(_ sender: UITapGestureRecognizer) {
        configurePicker()
    }
    
}
//MARK: - CLLocationDelegate

extension CreateEventViewController :  CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 14.0)
        self.mapView?.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
    }
   

}
//MARK: - GMSMapViewDelegate

extension CreateEventViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        let marker = GMSMarker(position: coordinate)
        marker.title = "Here Will be Your Event"
        marker.icon = UIImage(named: "arrowred")
        marker.map = mapView
        self.destination = marker
    }
}
//MARK: - ImagePickerDelegate&NavBarControllerDelegate

extension CreateEventViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker{
            imageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
//MARK: - TextFieldDelegate
extension CreateEventViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
