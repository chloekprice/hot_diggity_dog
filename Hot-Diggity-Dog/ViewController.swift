//
//  ViewController.swift
//  Hot-Diggity-Dog
//
//  Created by Chloe Price on 5/31/24.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {

    @IBOutlet weak var displayImage: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType  = .photoLibrary
        imagePicker.allowsEditing = false
        
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            displayImage.image = image
            guard let modelImage = CIImage(image: image) else {
                fatalError("issue with image file")
            }
            detectHotDog(image: modelImage)
        }
        imagePicker.dismiss(animated: true)
    }
    
    func detectHotDog(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3(configuration: MLModelConfiguration()).model) else {
            fatalError("issue with classification model")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("could not trigger request")
            }
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "HOT DIGGITY DOG"
                } else {
                    self.navigationItem.title = "HOT DIGGITY NAH"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
}
    


