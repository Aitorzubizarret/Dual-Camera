//
//  CamerasViewController.swift
//  Dual Camera
//
//  Created by Aitor Zubizarreta on 30/10/22.
//

import UIKit
import AVFoundation

final class CamerasViewController: UIViewController {
    
    // MARK: - Properties
    
    private let session = AVCaptureMultiCamSession()
    private let backCameraVideoDataOutput = AVCaptureVideoDataOutput()
    private let frontCameraVideoDataOutput = AVCaptureVideoDataOutput()
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkMultiCamSupport()
    }
    
    ///
    /// Checks if the iPhone model supports multi camera function.
    ///
    private func checkMultiCamSupport() {
        if AVCaptureMultiCamSession.isMultiCamSupported {
            print("Hola 1")
        } else {
            displayMultiCamNotSupportedAlertView()
        }
    }
    
    ///
    /// Displays an alert view to inform the user that the device does NOT support multi camera function.
    ///
    private func displayMultiCamNotSupportedAlertView() {
        let alertTitle = "Not supported"
        let alertMessage = "Your iPhone model does NOT support multi camera function."
        let alertView = UIAlertController(title: alertTitle,
                                          message: alertMessage,
                                          preferredStyle: .alert)
        
        let okActionTitle = "Ok"
        let okAction = UIAlertAction(title: okActionTitle, style: .default)
        
        alertView.addAction(okAction)
        
        present(alertView, animated: true)
    }
    
}
