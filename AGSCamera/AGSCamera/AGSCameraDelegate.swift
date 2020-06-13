//
//  AGSCameraDelegate.swift
//  AGSCamera
//
//  Created by M2015_001 on 13/06/20.
//  Copyright © 2020 Gowtham. All rights reserved.
//

import Foundation
import UIKit


public protocol AGSCameraDelegate: class {
//    /**
//     SwiftyCamViewControllerDelegate function called when when SwiftyCamViewController session did start running.
//     Photos and video capture will be enabled.
//     */
//    func AGSCamSessionDidStartRunning(_ AGSCam: AGESCamara)
//
//    /**
//     SwiftyCamViewControllerDelegate function called when when SwiftyCamViewController session did stops running.
//     Photos and video capture will be disabled.
//     */
//
//    func AGSCamSessionDidStopRunning(_ AGSCam: AGESCamara)
//
    /**
     SwiftyCamViewControllerDelegate function called when the takePhoto() function is called.
     
     - Parameter AGSCam: Current SwiftyCamViewController session
     - Parameter photo: UIImage captured from the current session
     */
    
    func AGSCam(_ AGSCam: AGESCamara, didTake photo: UIImage,imageData:Data)
    
}

