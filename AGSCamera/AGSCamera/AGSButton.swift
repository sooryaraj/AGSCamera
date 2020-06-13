//
//  AGSButton.swift
//  AGSCamera
//
//  Created by M2015_001 on 13/06/20.
//  Copyright © 2020 Gowtham. All rights reserved.
//

import Foundation
import UIKit

/// UIButton Subclass for Capturing Photo and Video with SwiftyCamViewController
open class AGSButton: UIButton {
    
    /// Delegate variable
    
    public weak var delegate: AGESCamara?
    
    // Sets whether button is enabled
    
    public var buttonEnabled = true
    
    /// Maximum duration variable
    
    fileprivate var timer : Timer?
    
    /// Initialization Declaration
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        delegate?.config()
    }
    
    /// Initialization Declaration
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate?.config()
    }
    
    /// UITapGestureRecognizer Function
    
    @objc fileprivate func Tap() {
        guard buttonEnabled == true else {
            return
        }
        
       delegate?.CapturePhoto()
    }
    
    // End timer if UILongPressGestureRecognizer is ended before time has ended
    
    fileprivate func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
}
