//
//  CamerasViewController.swift
//  Dual Camera
//
//  Created by Aitor Zubizarreta on 30/10/22.
//

import UIKit

final class CamerasViewController: UIViewController {
    
    // MARK: - UI Elements
    
    @IBOutlet weak var mainCameraOutputView: UIView!
    @IBOutlet weak var secondaryCameraOutputView: UIView!
    @IBOutlet weak var actionButtonsView: UIView!
    
    // MARK: - Properties
    
    var cameraManager: CameraManagerProtocol
    
    // MARK: - Methods
    
    init(cameraManager: CameraManagerProtocol) {
        self.cameraManager = cameraManager
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupView()
        checkCameraPermission()
    }
    
    private func setupView() {
        mainCameraOutputView.backgroundColor = UIColor.black
        secondaryCameraOutputView.backgroundColor = UIColor.black
    }
    
    private func checkCameraPermission() {
        cameraManager.hasCameraPermission { [weak self] granted in
            if granted {
                print("Camera access granted")
                self?.checkMultiCamSupport()
            } else {
                self?.displayCameraPermissionNotGrantedAlertView()
                print("Camera access NOT granted")
            }
        }
    }
    
    private func checkMultiCamSupport() {
        if cameraManager.isMultiCamSupported() {
            print("Multicam supported")
            cameraManager.setupCameraOutputs(frontCameraPreviewView: mainCameraOutputView,
                                             backCameraPreviewView: secondaryCameraOutputView)
            cameraManager.setupCameraSession()
            
            if cameraManager.isFrontCaptureDeviceReady() {
                cameraManager.displayFrontCaptureDeviceOutput()
            } else {
                print("No Front Capture Device Ready.")
            }
            
            if cameraManager.isBackCaptureDeviceReady() {
                cameraManager.displayBackCaptureDeviceOutput()
            } else {
                print("No Back Capture Device Ready.")
            }
        } else {
            displayMultiCamNotSupportedAlertView()
        }
    }
    
    ///
    /// Displays an alert view to inform the user that the app has no camera permission.
    ///
    private func displayCameraPermissionNotGrantedAlertView() {
        DispatchQueue.main.async { [weak self] in
            let alertTitle = "Permission not granted"
            let alertMessage = "App has NO camera permission."
            let alertView = UIAlertController(title: alertTitle,
                                              message: alertMessage,
                                              preferredStyle: .alert)
            
            let okActionTitle = "Ok"
            let okAction = UIAlertAction(title: okActionTitle, style: .default)
            
            alertView.addAction(okAction)
            
            self?.present(alertView, animated: true)
        }
    }
    
    ///
    /// Displays an alert view to inform the user that the device does NOT support multi camera function.
    ///
    private func displayMultiCamNotSupportedAlertView() {
        DispatchQueue.main.async { [weak self] in
            let alertTitle = "Not supported"
            let alertMessage = "Your iPhone model does NOT support multi camera function."
            let alertView = UIAlertController(title: alertTitle,
                                              message: alertMessage,
                                              preferredStyle: .alert)
            
            let okActionTitle = "Ok"
            let okAction = UIAlertAction(title: okActionTitle, style: .default)
            
            alertView.addAction(okAction)
            
            self?.present(alertView, animated: true)
        }
    }
    
}
