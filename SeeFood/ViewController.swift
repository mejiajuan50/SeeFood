//
//  ViewController.swift
//  SeeFood
//
//  Created by Juan Mejia on 9/26/18.
//  Copyright © 2018 Juan Mejia. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var photoView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            photoView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else { fatalError("Could not convert to CIImage")}
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
       
    }
    
    func detect(image: CIImage) {
    
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else { fatalError("Loading CoreML Model Failed.")}
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let results = request.results as? [VNClassificationObservation] else { fatalError("Model failed to process image")}
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.green
                }
                else {
                    self.navigationItem.title = "Not Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.red
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
    
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

