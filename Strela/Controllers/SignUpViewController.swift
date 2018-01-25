//
//  SignUpViewController.swift
//  Strela
//
//  Created by Vitalii Kulak on 11/15/17.
//  Copyright © 2017 Vitalii Kulak. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController{
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var birthdayDataPicker: UIDatePicker!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    //MARK: - Properties
    
    let imagePicker = UIImagePickerController()
    //MARK: - ViewConfig
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        birthdayDataPicker.maximumDate = Date()
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
    
   
    
    // MARK: - Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func configureView() {
        userNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        phoneNumberTextField.delegate = self
    }
    
    private func configurePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func keyboardWillHide() {
        self.view.frame.origin.y = 0
    }
    
    @objc func keyboardWillChange(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if passwordTextField.isFirstResponder {
                self.view.frame.origin.y = -keyboardSize.height
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func SignUpAction(_ sender: Any) {
        guard let email = emailTextField.text,
            email != "",
            let password = passwordTextField.text,
            password != "",
            let userName = userNameTextField.text,
            userName != "",
            let phoneNumber = phoneNumberTextField.text,
            phoneNumber != ""
        else  {
                AlertController.showAlert(self, title: "Missing Info", message: "Please fill out all fields")
                return
        }
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            if error == nil {
                    //Add User to DatabaseFirebase
                    guard let uid = user?.uid else {
                        return
                    }
                let imageName = NSUUID().uuidString
                
                if let uploadData = UIImagePNGRepresentation(self.imageView.image!) {
                    DatabaseService.shared.storageReference.child("profileImages").child("\(imageName).png").putData(uploadData, metadata: nil, completion: { (metadata, error) in
                        if error != nil {
                            return
                        }
                        if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                            
                            let formatter = DateFormatter()
                            formatter.dateFormat = "dd/MM/yyyy"
                            let birthdayString = formatter.string(from: self.birthdayDataPicker.date)
                            
                            //Gender
                            var gender: String?
                            switch self.genderSegmentedControl.selectedSegmentIndex {
                            case 0: gender = "Male"
                            case 1: gender = "Female"
                            default: break
                            }
                            
                            let userParameters = ["userName"    : self.userNameTextField.text!,
                                                  "phoneNumber" : self.phoneNumberTextField.text!,
                                                  "userUid"     : uid,
                                                  "email"       : self.emailTextField.text!,
                                                  "profileImageURL" : profileImageUrl,
                                                  "gender"      : gender!,
                                                  "birthday"    : birthdayString] as [String : Any]
                            DatabaseService.shared.usersReference.child(uid).setValue(userParameters)
                        }else{
                            AlertController.showAlert(self, title: "Error", message: error!.localizedDescription)
                        }
                    })
                }
            }
        })
        let mapViewController = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController")
        self.present(mapViewController!, animated: true, completion: nil)

    }
  
    @IBAction func choseUserPhotoAction(_ sender: UITapGestureRecognizer) {
        configurePicker()
    }
    
    @IBAction func moveToLoginViewController(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - Image Picker Delegate

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
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

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
