//
//  VideoViewController.swift
//  LambdaTimeline
//
//  Created by Carolyn Lea on 10/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class VideoViewController: UIViewController, AVCaptureFileOutputRecordingDelegate
{

    @IBOutlet var previewView: CameraPreviewView!
    var postController: PostController!
    @IBOutlet var recordButton: UIButton!
    private var captureSession: AVCaptureSession!
    private var recordOutput: AVCaptureMovieFileOutput!
    @IBOutlet var videoTitleTextField: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupCapture()
    }
    
    private func setupCapture()
    {
        let captureSession = AVCaptureSession()
        let device = bestCamera()
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(videoDeviceInput) else
        {
            fatalError()
        }
        captureSession.addInput(videoDeviceInput)
        
        let fileOutput = AVCaptureMovieFileOutput()
        guard captureSession.canAddOutput(fileOutput) else {fatalError()}
        captureSession.addOutput(fileOutput)
        recordOutput = fileOutput
        captureSession.sessionPreset = .hd1920x1080
        captureSession.commitConfiguration()
        
        self.captureSession = captureSession
        previewView.videoPreviewLayer.session = captureSession
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    private func bestCamera() -> AVCaptureDevice
    {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
        {
            return device
        }
        else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        {
            return device
        }
        else
        {
            fatalError("Missing expected back camera device")
        }
    }
    
    @IBAction func toggleRecording(_ sender: Any)
    {
        if recordOutput.isRecording
        {
            recordOutput.stopRecording()
           
            
        }
        else
        {
            recordOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    
    private func newRecordingURL() -> URL
    {
        let fm = FileManager.default
        let documentsDir = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        return documentsDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
    }
    
    private func updateViews()
    {
        guard isViewLoaded else {return}
        
        let recordButtonImageName = recordOutput.isRecording ? "Stop" : "Record"
        recordButton.setImage(UIImage(named: recordButtonImageName), for: .normal)
    }
    
    // MARK: AVCaptureFileOutputRecordingDelegate
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection])
    {
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?)
    {
        
        DispatchQueue.main.async {
            self.updateViews()
            PHPhotoLibrary.requestAuthorization({(status) in
                if status != .authorized
                {
                    NSLog("Please give permission")
                    return
                }
                PHPhotoLibrary.shared().performChanges ({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
                    
                    guard let data = try? Data(contentsOf: self.newRecordingURL()) else {return}
                    self.postController.createPost(with: "Title", ofType: .video, mediaData: data, ratio: (self.previewView.bounds.height)/(self.previewView.bounds.width)) { (success) in
                        print("success")
                    }
                    
                    
                    let alert = UIAlertController(title: "Your video was saved to your Photo Library", message: nil, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    
                }, completionHandler: { (success, error) in
                    if let error = error {
                        NSLog("error saving: \(error)")
                    }
                })
            })
        }
    }
}
