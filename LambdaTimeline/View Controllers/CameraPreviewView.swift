//
//  CameraPreviewView.swift
//  LambdaTimeline
//
//  Created by Carolyn Lea on 10/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPreviewView: UIView
{
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer
    {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    override class var layerClass: AnyClass
    {
        return AVCaptureVideoPreviewLayer.self
    }
    
    
}
