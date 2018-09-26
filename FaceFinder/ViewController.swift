//
//  ViewController.swift
//  FaceFinder
//
//  Created by Vartan on 9/26/18.
//  Copyright © 2018 Vartan. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var msgLabel: UILabel!
    
     override func viewDidLoad() {
        super.viewDidLoad()
        spinner.hidesWhenStopped = true
        setupImageView()
 
    }
  
    // MARK: Setting up Image View Programmatically
    func setupImageView() {
        
        guard let image = UIImage(named: "faces") else { return }
        
        guard let cgImage = image.cgImage else {
            print("Could not find CGImage")
            return
        }
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        
        let scaledHeight = (view.frame.width / image.size.width) * image.size.height
        
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scaledHeight)
        view.addSubview(imageView)
        
        spinner.startAnimating()
        
        // Pass in our cgImage here.
        
        // Making performVisionRequest to happen in the background thread.
        DispatchQueue.global(qos: .background).async {
         
            self.performVisionRequest(for: cgImage, with: scaledHeight)
       
        }
    
        
        
    }
    
    //Draws a UI View Outline for finding faces
    func createFaceOutline(for rectangle: CGRect) {
        
        let yellowView = UIView()
        yellowView.backgroundColor = .clear
        yellowView.layer.borderColor = UIColor.yellow.cgColor
        yellowView.layer.borderWidth = 3
        yellowView.layer.cornerRadius = 5
        yellowView.alpha = 0.0
        yellowView.frame = rectangle
        self.view.addSubview(yellowView)
        
        UIView.animate(withDuration: 0.3) {
            
            // Fade in yellow view.
            yellowView.alpha = 0.75
            
            // hide spinner
            self.spinner.alpha = 0.0
          
            //hide label
            self.msgLabel.alpha = 0.0
            
        }
        
        self.spinner.stopAnimating()
        
        
    }
    
    
    
    func performVisionRequest(for image: CGImage, with scaledHeight: CGFloat) {
        
        let faceDetectionRequest = VNDetectFaceRectanglesRequest { (request, error) in
            
            if let error = error {
                print("Failed to detect face: ", error)
                return
            }
            
            // Pull out the results from our request.
            request.results?.forEach({ (result) in
                
                
                guard let faceObservation = result as? VNFaceObservation else { return }
                
                // Create a face rectangle and put it in the Main Thread.
                
                // NOTE: DispatchQueue.main.async will fix the problem when the app runs and we
                // see the process of the spinner and label.
                DispatchQueue.main.async {
                  
                    // getting the width and trying to scale it down to match with the image of the face.
                    let width = self.view.frame.width * faceObservation.boundingBox.width
                    
                    // getting the height and trying to scale it down to match with the height of the face.
                    let height = scaledHeight * faceObservation.boundingBox.height
                    
                    let x = self.view.frame.width * faceObservation.boundingBox.origin.x
                    
                    let y = scaledHeight * (1 - faceObservation.boundingBox.origin.y) - height
                    
                    
                   
                    let faceRectangle = CGRect(x: x, y: y, width: width, height: height)
                    self.createFaceOutline(for: faceRectangle)
                }
         
                
            })
            
            
        }
        
        
        // Create the handler to pass in the request above.
        let imageRequestHandler = VNImageRequestHandler(cgImage: image, options: [:])
       
        // This is where the error will be thrown at.
        do {
            try imageRequestHandler.perform([faceDetectionRequest])
       
        } catch {
           
            print("Failed to perform image request", error.localizedDescription)
            return
      
        }
        
      
        
    }


}

