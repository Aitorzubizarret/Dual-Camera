//
//  CamerasViewController.swift
//  Dual Camera
//
//  Created by Aitor Zubizarreta on 30/10/22.
//

import UIKit
import PhotosUI

final class CamerasViewController: UIViewController {
    
    // MARK: - UI Elements
    
    @IBOutlet weak var dualCameraView: DualCameraView!
    
    @IBOutlet weak var changeCamerasButton: UIButton!
    @IBAction func changeCamerasButtonTapped(_ sender: Any) {
        changeCamerasAction()
    }
    
    @IBOutlet weak var actionButtonsView: UIView!
    @IBOutlet weak var galleryPreviewImageView: UIImageView!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBAction func takePhotoButtonTapped(_ sender: Any) {
        takePhotoAction()
    }
    
    // MARK: - Properties (from )
    
    var presenter: CamerasPresenterProtocol?
    
    // MARK: - Methods
    
    init(presenter: CamerasPresenterProtocol) {
        self.presenter = presenter
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("View viewWillDisappear")
        presenter?.viewWillDisappear()
        
//        cameraManager.stopSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presenter?.checkCameraPermission()
        
        dualCameraView.setupViewSize(maxWidth: dualCameraView.frame.width, maxHeight: dualCameraView.frame.height)
    }
    
    private func setupView() {
        // View.
        dualCameraView.backgroundColor = UIColor.black
        
        // ImageView.
        galleryPreviewImageView.layer.cornerRadius = 6
        
        // Tap Gesture Recognizer.
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(showPhotoAlbum))
        galleryPreviewImageView.addGestureRecognizer(tapGR)
        galleryPreviewImageView.isUserInteractionEnabled = true
        
        // Button.
        takePhotoButton.layer.cornerRadius = takePhotoButton.frame.height / 2
        changeCamerasButton.layer.cornerRadius = changeCamerasButton.frame.height / 2
        changeCamerasButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        changeCamerasButton.layer.borderWidth = 1
        changeCamerasButton.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
    }
    
    /// Displays an alert view to inform the user that the app has no camera permission.
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
    
    /// Displays an alert view to inform the user that the device does NOT support multi camera function.
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
    
    @objc private func showPhotoAlbum() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let photoPickerVC = PHPickerViewController(configuration: configuration)
        photoPickerVC.delegate = self
        
        self.present(photoPickerVC, animated: true, completion: nil)
    }
    
    private func changeCamerasAction() {
        presenter?.changeCameras()
    }
    
    private func takePhotoAction() {
        // Haptic Feedback.
        let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
        hapticFeedback.impactOccurred()
        
        presenter?.takePhoto()
    }
    
}

extension CamerasViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
    }
    
}

// MARK: - CamearasViewProtocol

extension CamerasViewController: CamerasViewProtocol {
    
    func onCameraPermissionNotGranted() {
        displayCameraPermissionNotGrantedAlertView()
    }
    
    func onCameraPermissionGranted() {
        presenter?.checkMultiCamSupport()
    }
    
    func onMultiCamNotSupported() {
        displayMultiCamNotSupportedAlertView()
    }
    
    func onMultiCamSupported() {
        presenter?.setup(dualCameraView: dualCameraView)
    }
    
}
