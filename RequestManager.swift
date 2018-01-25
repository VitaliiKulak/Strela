//
//  RequestManager.swift
//  Strela
//
//  Created by Vitalii Kulak on 1/14/18.
//  Copyright © 2018 Vitalii Kulak. All rights reserved.
//

import Foundation
import UIKit

class RequestManager {
    
    static let shared = RequestManager()
    
    func getImage(url: String, completionHandler:@escaping (UIImage) -> ()) {
        if let url = URL(string: url) {
            let session = URLSession(configuration: .default)
            let getImageFromUrl = session.dataTask(with: url, completionHandler: { (data, response, error) in
                DispatchQueue.main.async {
                    if let data = data {
                        let image: UIImage = UIImage(data: data)!
                        completionHandler(image)
                    } else {
                        print("Unable to load image")
                    }
                }
            })
            getImageFromUrl.resume()
        }
    }
    
    
    
}
