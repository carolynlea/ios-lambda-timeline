//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos

class ImagePostViewController: ShiftableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        originalImage = imageView.image
        setImageViewHeight(with: 1.0)
        
        updateViews()
        brightnessLabel.isHidden = true
        contrastLabel.isHidden = true
        saturationLabel.isHidden = true
        intensityLabel.isHidden = true
        brightnessSlider.isHidden = true
        contrastSlider.isHidden = true
        saturationSlider.isHidden = true
        intensitySlider.isHidden = true
    }
    
    
    func updateViews() {
        
        guard let originalImage = originalImage else {
                title = "New Post"
                return
        }
        
        title = post?.title
        
        setImageViewHeight(with: originalImage.ratio)
        
        //imageView.image = image(byFiltering: originalImage)
        
        chooseImageButton.setTitle("", for: [])
    }
    
    private func presentImagePickerController() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary

        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createPost(_ sender: Any) {
        
        view.endEditing(true)
        
        guard let imageData = imageView.image?.jpegData(compressionQuality: 0.1),
            let title = titleTextField.text, title != "" else {
            presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
            return
        }
        
        postController.createPost(with: title, ofType: .image, mediaData: imageData, ratio: imageView.image?.ratio) { (success) in
            guard success else {
                DispatchQueue.main.async {
                    self.presentInformationalAlertController(title: "Error", message: "Unable to create post. Try again.")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            presentImagePickerController()
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { (status) in
                
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                    return
                }
                
                self.presentImagePickerController()
            }
            
        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
            
        }
        presentImagePickerController()
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    
    // MARK: - SliderActions
    
    @IBAction func addFilter(_ sender: Any)
    {
        let alertController = UIAlertController(title:"Choose Filter", message: "Do it!", preferredStyle:.actionSheet)
        
        let blur = UIAlertAction.init(title: "Gaussian Blur", style: .default) { (UIAlertAction) in
            self.applyBlur()
        }
        let sepia = UIAlertAction.init(title: "Sepia", style: .default) { (UIAlertAction) in
            self.applySepia()
        }
        let noir = UIAlertAction.init(title: "Noir", style: .default) { (UIAlertAction) in
            self.applyNoirEffect()
        }
        let effectTransfer = UIAlertAction.init(title: "Photo Effect Process", style: .default) { (UIAlertAction) in
            self.applyPhotoTransferEffect()
        }
        
        let manual = UIAlertAction.init(title: "Manual Adjustment", style: .default) { (UIAlertAction) in
            
            self.brightnessLabel.isHidden = false
            self.contrastLabel.isHidden = false
            self.saturationLabel.isHidden = false
            self.brightnessSlider.isHidden = false
            self.contrastSlider.isHidden = false
            self.saturationSlider.isHidden = false
            self.applyManualEffect()
        }
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel)
        
        alertController.addAction(blur)
        alertController.addAction(sepia)
        alertController.addAction(noir)
        alertController.addAction(effectTransfer)
        alertController.addAction(manual)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //"CIBumpDistortion", "CIPixellate", "CITwirlDistortion", "CIUnsharpMask", "CIVignette"
    @IBAction func applySepia()
    {
        guard let image = imageView.image else {return}
        imageView.image = applyFilterTo(image: image, filterEffect: Filter(filterName: "CISepiaTone", filterEffectValue: 0.90, filterEffectValueName: kCIInputIntensityKey))
    }
    func applyPhotoTransferEffect()
    {
        guard let image = imageView.image else {return}
        imageView.image = applyFilterTo(image: image, filterEffect: Filter(filterName: "CIPhotoEffectProcess", filterEffectValue: nil, filterEffectValueName: nil))
    }
    func applyNoirEffect()
    {
        guard let image = imageView.image else {return}
        imageView.image = applyFilterTo(image: image, filterEffect: Filter(filterName: "CIPhotoEffectNoir", filterEffectValue: nil, filterEffectValueName: nil))
    }
    func applyBlur()
    {
        guard let image = imageView.image else {return}
        imageView.image = applyFilterTo(image: image, filterEffect: Filter(filterName: "CIGaussianBlur", filterEffectValue: 8.0, filterEffectValueName: kCIInputRadiusKey))
    }
    
    func applyManualEffect()
    {
        
        updateImage()

    }
    @IBAction func clearFilters(_ sender: Any)
    {
        imageView.image = originalImage
    }
    
    @IBAction func brightness(_ sender: Any)
    {
        updateImage()
    }
    
    @IBAction func contrast(_ sender: Any)
    {
        updateImage()
    }
    
    @IBAction func saturation(_ sender: Any)
    {
        updateImage()
    }
    
    @IBAction func intensity(_ sender: Any)
    {
        updateViews()
    }
    
    // MARK: Private
    private func applyFilterTo(image: UIImage, filterEffect: Filter) -> UIImage?
    {
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter(name: filterEffect.filterName)
        
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        if let filterEffectValue = filterEffect.filterEffectValue,
            let filterEffectValueName = filterEffect.filterEffectValueName
        {
            filter?.setValue(filterEffectValue, forKey: filterEffectValueName)
        }
        
        var filteredImage: UIImage?
        
        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage,
            let cgiImageResult = context.createCGImage(output, from: output.extent)
        {
            filteredImage = UIImage(cgImage: cgiImageResult)
        }
        
        return filteredImage
    }
    
    private func updateImage()
    {
        guard let originalImage = originalImage else {return}
        imageView?.image = image(byFiltering: originalImage)
        
    }
    
    private func image(byFiltering image: UIImage) -> UIImage?
    {
        guard let cgImage = image.cgImage else {return image}
        
        let ciImage = CIImage(cgImage: cgImage)
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(brightnessSlider.value, forKey: kCIInputBrightnessKey)
        filter.setValue(contrastSlider.value, forKey: kCIInputContrastKey)
        filter.setValue(saturationSlider.value, forKey: kCIInputSaturationKey)

//        sepiaFilter?.setValue(filter.outputImage, forKey: kCIInputImageKey)
//        sepiaFilter?.setValue(intensitySlider.value, forKey: kCIInputIntensityKey)
//
//        splashFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let outputCIImage = filter.outputImage,
        //guard let outputCIImage = splashFilter?.outputImage,
            let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {return nil}
        return UIImage(cgImage: outputCGImage)
        
    }
    
    
    // MARK: - Outlets and Properties
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    {
        didSet
        {
            guard let imageData = imageData else {return}
            originalImage = UIImage(data: imageData)
        }
    }
    private let filter = CIFilter(name: "CIColorControls")!
    private let sepiaFilter = CIFilter(name: "CISepiaTone")
    private let splashFilter = CIFilter(name: "CICircleSplashDistortion")
    
    private let context = CIContext(options: nil)
    private var originalImage: UIImage?
    {
        didSet
        {
            updateViews()
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    @IBOutlet var brightnessSlider: UISlider!
    @IBOutlet var contrastSlider: UISlider!
    @IBOutlet var saturationSlider: UISlider!
    @IBOutlet var intensitySlider: UISlider!
    
    @IBOutlet var brightnessLabel: UILabel!
    @IBOutlet var contrastLabel: UILabel!
    @IBOutlet var saturationLabel: UILabel!
    @IBOutlet var intensityLabel: UILabel!
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        originalImage = image
        imageView.image = originalImage
        
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

struct Filter
{
    let filterName: String
    var filterEffectValue: Any?
    var filterEffectValueName: String?
    
    init(filterName: String, filterEffectValue: Any?, filterEffectValueName: String?)
    {
        self.filterName = filterName
        self.filterEffectValue = filterEffectValue
        self.filterEffectValueName = filterEffectValueName
    }
}
//enum FilterType : String
//{
//    case Chrome = "CIPhotoEffectChrome"
//    case Fade = "CIPhotoEffectFade"
//    case Instant = "CIPhotoEffectInstant"
//    case Mono = "CIPhotoEffectMono"
//    case Noir = "CIPhotoEffectNoir"
//    case Process = "CIPhotoEffectProcess"
//    case Tonal = "CIPhotoEffectTonal"
//    case Transfer =  "CIPhotoEffectTransfer"
//    case Sepia = "CISepiaTone"
//    //case Vignette = "CIVignette"
//    //case VignetteEffect = "CIVignetteEffect"
//}
//
//extension UIImage
//{
//    func addFilter(filter : FilterType) -> UIImage
//    {
//        let filter = CIFilter(name: filter.rawValue)
//
//        // convert UIImage to CIImage and set as input
//        let ciInput = CIImage(image: self)
//        filter?.setValue(ciInput, forKey: "inputImage")
//        // get output CIImage, render as CGImage first to retain proper UIImage scale
//        let ciOutput = filter?.outputImage
//        let ciContext = CIContext()
//        let cgImage = ciContext.createCGImage(ciOutput!, from: (ciOutput?.extent)!)
//        //Return the image
//        return UIImage(cgImage: cgImage!)
//    }
//}
