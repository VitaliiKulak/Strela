//
//  ViewController.swift
//  Strela
//
//  Created by Vitalii Kulak on 11/11/17.
//  Copyright © 2017 Vitalii Kulak. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    //MARK: - IBOutlets
    
    //MARK: - Properties
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    //MARK: - IBActions
    @IBAction func SignUpSegue(_ sender: Any) {
        let SignUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController")
        self.present(SignUpViewController!, animated: true, completion: nil)
    }
   
    @IBAction func LogInSegue(_ sender: Any) {
        let LogInViewController = self.storyboard?.instantiateViewController(withIdentifier: "LogInViewController")
        self.present(LogInViewController!, animated: true, completion: nil)
    }
    
}

