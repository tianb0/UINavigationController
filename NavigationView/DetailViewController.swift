//
//  DetailViewController.swift
//  NavigationView
//
//  Created by Tianbo Qiu on 12/18/22.
//

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet var nameField: UITextField!
    @IBOutlet var uidField: UITextField!
    @IBOutlet var valueField: UITextField!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    var item: Item! {
        didSet {
            navigationItem.title = item.name
        }
    }
    
    var imageStore: ImageStore!
    
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nameField.text = item.name
        uidField.text = item.uid
        valueField.text = numberFormatter.string(from: NSNumber(value: item.value))
        dateLabel.text = dateFormatter.string(from: item.createdAt)
        
        let imageToDisplay = imageStore.image(forKey: item.itemKey)
        imageView.image = imageToDisplay
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // dismiss keyboard
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func backgroundTapped() {
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        if let name = nameField.text {
            item.name = name
        }
        if let uid = uidField.text {
            item.uid = uid
        }
        if let valueText = valueField.text, let value = numberFormatter.number(from: valueText) {
            item.value = value.intValue
        }
    }
    
    @IBAction func choosePhotoSource(_ sender: UIBarButtonItem) {
        //        print("pressed")
        
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        alertController.modalPresentationStyle = .popover
        alertController.popoverPresentationController?.barButtonItem = sender
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera",
                                             style: .default) { _ in
                let imagePicker = self.imagePicker(for: .camera)
                self.present(imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(cameraAction)
            
        }
        
        let photoAction = UIAlertAction(title: "Photo Library",
                                        style: .default) { _ in
            let imagePicker = self.imagePicker(for: .photoLibrary)
            imagePicker.modalPresentationStyle = .popover
            imagePicker.popoverPresentationController?.barButtonItem = sender
            self.present(imagePicker, animated: true, completion: nil)
            
        }
        
        alertController.addAction(photoAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePicker(for sourceType: UIImagePickerController.SourceType) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        return imagePicker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // get picked image from info dictionary
        let image = info[.originalImage] as! UIImage
        
        // store the image in the ImageStore for the item's key
        imageStore.setImage(image, forKey: item.itemKey)
        
        // put that image on the screen in the image view
        imageView.image = image
        
        // take image picker off the screen - you must call this dismiss method
        dismiss(animated: true, completion: nil)
    }
}
