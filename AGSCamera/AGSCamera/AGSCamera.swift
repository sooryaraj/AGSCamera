//
//  AGSCamera.swift
//  AGSCamera
//
//  Created by M2015_001 on 13/06/20.
//  Copyright © 2020 Gowtham. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

open class AGESCamara{

    /// Enumeration for Camera Selection
    public enum CameraSelection: String {

        /// Camera on the back of the device
        case rear = "rear"

        /// Camera on the front of the device
        case front = "front"
    }
    
    public enum FlashMode{
        //Return the equivalent AVCaptureDevice.FlashMode
        var AVFlashMode: AVCaptureDevice.FlashMode {
            switch self {
                case .on:
                    return .on
                case .off:
                    return .off
                case .auto:
                    return .auto
            }
        }
        //Flash mode is set to auto
        case auto
        
        //Flash mode is set to on
        case on
        
        //Flash mode is set to off
        case off
    }
    
    /// Returns true if the capture session is currently running
    private(set) public var isSessionRunning     = false
    
    /// Returns the CameraSelection corresponding to the currently utilized camera
    private(set) public var currentCamera        = CameraSelection.rear
    
    /// Current Capture Session
    public let session                           = AVCaptureSession()
    
    /// Photo File Output variable
    fileprivate var photoFileOutput              : AVCapturePhotoOutput?

    /// Boolean to store when View Controller is notified session is running
    fileprivate var sessionRunning               = false
    
    /// Sets whether or not View Controller supports auto rotation
     public var allowAutoRotate                = false
    
    /// Disable view autorotation for forced portrait recorindg
    public var shouldAutorotate: Bool {
        return allowAutoRotate
    }
    
    /// Set default launch camera
    public var defaultCamera                   = CameraSelection.rear
    
    /// Video Device variable
    fileprivate var videoDevice                  : AVCaptureDevice?

    /// Public Camera Delegate for the Custom View Controller Subclass
    public weak var cameraDelegate: AGSCameraDelegate?
    
    ///  private photo capture delegate
    
    fileprivate var PhotoCaptureDelegate:AVCapturePhotoCaptureDelegate?
    
    /// Configure Photo Output
    fileprivate func configurePhotoOutput() {
        let stimageout = AVCapturePhotoOutput()
        let settings = AVCapturePhotoSettings()
        settings.livePhotoVideoCodecType = .jpeg
        stimageout.capturePhoto(with: settings, delegate: PhotoCaptureDelegate!.self)
    }

    /**
    Returns a UIImage from Image Data.
    - Parameter imageData: Image Data returned from capturing photo from the capture session.
    - Returns: UIImage from the image data, adjusted for proper orientation.
    */

    fileprivate func processPhoto(_ imageData: Data) -> UIImage {
        let dataProvider = CGDataProvider(data: imageData as CFData)
        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)

        // Set proper orientation for photo
        // If camera is currently set to front camera, flip image
        let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: .down)

        return image
    }
    
    /// Get Devices
    fileprivate class func deviceWithMediaType(_ mediaType: String, preferringPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        if #available(iOS 10.0, *) {
                let avDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType(rawValue: mediaType), position: position)
                return avDevice
        } else {
                // Fallback on earlier versions
                let avDevice = AVCaptureDevice.devices(for: AVMediaType(rawValue: mediaType))
                var avDeviceNum = 0
                for device in avDevice {
                        print("deviceWithMediaType Position: \(device.position.rawValue)")
                        if device.position == position {
                                break
                        } else {
                                avDeviceNum += 1
                        }
                }

                return avDevice[avDeviceNum]
        }

        //return AVCaptureDevice.devices(for: AVMediaType(rawValue: mediaType), position: position).first
    }
    
    public func CapturePhoto() {

        guard let device = videoDevice else {
            return
        }

        if device.hasFlash == true /* TODO: Add Support for Retina Flash and add front flash */ {
            changeFlashSettings(device: device)
        }
        capturePhotoAsyncronously(completionHandler: { (_) in })
    }
    
    public func config(){
        session.beginConfiguration()
        
        // Set default camera
        currentCamera = defaultCamera
        configurePhotoOutput()
        
        session.commitConfiguration()
    }
    
    fileprivate func changeFlashSettings(device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
            device.torchMode = AVCaptureDevice.TorchMode.on
            device.unlockForConfiguration()
        } catch {
            print("[SwiftyCam]: \(error)")
        }
    }
    fileprivate func capturePhotoAsyncronously(completionHandler: @escaping(Bool) -> ()) {
        guard sessionRunning == true else {
            print("[SwiftyCam]: Cannot take photo. Capture session is not running")
            return
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
                if let error = error {
                    print(error.localizedDescription)
                }
                if (photoSampleBuffer != nil) {
                    if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
                        print("image: \(String(describing: UIImage(data: dataImage)?.size))") // Your Image
    //                    showImage()
                        let image = self.processPhoto(dataImage)

                         // Call delegate and return new image
                         DispatchQueue.main.async {
                            self.cameraDelegate?.AGSCam(self, didTake: image,imageData:dataImage)
                         }
                         completionHandler(true)
                    }
               } else {
                   completionHandler(false)
               }
        }
    }
    
}
