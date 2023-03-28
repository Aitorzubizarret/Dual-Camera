//
//  CameraManager.swift
//  Dual Camera
//
//  Created by Aitor Zubizarreta on 1/11/22.
//

import UIKit
import AVFoundation

final class CameraManager: NSObject {
    
    // MARK: - Properties (from CameraManagerProtocol)
    
    var session: AVCaptureMultiCamSession? // AVCaptureSession?
    
    var dualCameraView: DualCameraView?
    
    var frontCaptureDevice: AVCaptureDevice?
    var frontCaptureDeviceInput: AVCaptureDeviceInput?
    var frontCaptureDevicePreviewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer()
    
    var backCaptureDevice: AVCaptureDevice?
    var backCaptureDeviceInput: AVCaptureDeviceInput?
    var backCaptureDevicePreviewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer()
    
    var backCameraOutput: AVCapturePhotoOutput?
    var frontCameraOutput: AVCapturePhotoOutput?
    
    // MARK: - Properties (from CameraManagerToPresenterProtocol)
    
    var presenter: CamerasPresenterToCameraManagerProtocol?
    
    // MARK: - Properties
    
    private var isBackCameraMain: Bool = true
    
    private var mainPhotoData: Data?
    private var secondaryPhotoData: Data?
    
}

// MARK: - CameraManagerProtocol

extension CameraManager: CameraManagerProtocol {
    
    func hasCameraPermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            print("✅ Camera Auth permission : Authorized")
            completion(true)
        case .notDetermined:
            print("❓ Camera Auth permission : NotDetermined")
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        case .denied:
            print("❌ Camera Auth permission : Denied")
            completion(false)
        case .restricted:
            print("❌ Camera Auth permission : Restricted")
            completion(false)
        default: // For future status types.
            print("❓ Camera Auth permission : Default")
            completion(false)
        }
    }
    
    func isMultiCamSupported() -> Bool {
        return AVCaptureMultiCamSession.isMultiCamSupported
    }
    
    func setup(dualCameraView: DualCameraView) {
        // Setups the Front and Back Camera Preview Views.
        self.dualCameraView = dualCameraView
        
        createMulticamSession()
        
        configureBackCamera()
        configureFrontCamera()
        
        startSession()
        
        DispatchQueue.main.async { [weak self] in
            self?.displayBackCamera()
            self?.displayFrontCamera()
        }
    }
    
    func configureBackCamera() {
        // Check if there is any Back Capture Device (Camera) ready.
        let backCaptureDeviceDiscoverSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                                mediaType: .video,
                                                                                position: .back)
        
        let backCaptureDevices: [AVCaptureDevice] = backCaptureDeviceDiscoverSession.devices
        
        if backCaptureDevices.isEmpty {
            print("No Back Capture Device (Camera) ready")
        } else {
            backCaptureDevice = backCaptureDevices.first
            guard let backCaptureDevice = self.backCaptureDevice,
                  let backCaptureDeviceInput = try? AVCaptureDeviceInput(device: backCaptureDevice),
                  let session = self.session,
                  session.canAddInput(backCaptureDeviceInput) else { return }
            
            self.backCaptureDeviceInput = backCaptureDeviceInput
            session.addInput(backCaptureDeviceInput)
            
            // Create the Output.
            backCameraOutput = AVCapturePhotoOutput()
            
            guard let backCameraOutput = self.backCameraOutput,
                  session.canAddOutput(backCameraOutput) else { return }
            
            session.addOutput(backCameraOutput)
        }
    }
    
    func displayBackCamera() {
        guard let dualCameraView = self.dualCameraView,
              let mainCameraLayer = dualCameraView.mainCameraLayer,
              let secondaryCameraLayer = dualCameraView.secondaryCameraLayer,
              let session = self.session else { return }
        
        // Displays the Back Capture Device (camera) output in the Preview View.
        backCaptureDevicePreviewLayer.session = session
        backCaptureDevicePreviewLayer.videoGravity = .resizeAspectFill
        backCaptureDevicePreviewLayer.connection?.videoOrientation = .portrait
        
        if isBackCameraMain {
            backCaptureDevicePreviewLayer.frame.size = mainCameraLayer.frame.size
            mainCameraLayer.sublayers = nil
            mainCameraLayer.addSublayer(backCaptureDevicePreviewLayer)
        } else {
            backCaptureDevicePreviewLayer.frame.size = secondaryCameraLayer.frame.size
            secondaryCameraLayer.sublayers = nil
            secondaryCameraLayer.addSublayer(backCaptureDevicePreviewLayer)
        }
    }
    
    func configureFrontCamera() {
        // Checks if there is any Front capture device (camera) ready.
        let frontDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                     mediaType: .video,
                                                                     position: .front)
        
        let frontDevices = frontDiscoverySession.devices
        
        if frontDevices.isEmpty {
            print("❌ Front Capture Device NOT ready.")
        } else {
            self.frontCaptureDevice = frontDevices.first
            
            guard let frontCaptureDevice = self.frontCaptureDevice,
                  let frontCaptureDeviceInput = try? AVCaptureDeviceInput(device: frontCaptureDevice),
                  let session = self.session,
                  session.canAddInput(frontCaptureDeviceInput) else { return }
            
            self.frontCaptureDeviceInput = frontCaptureDeviceInput
            session.addInput(frontCaptureDeviceInput)
            
            // Create the Output.
            frontCameraOutput = AVCapturePhotoOutput()
            
            guard let frontCameraOutput = self.frontCameraOutput,
                  session.canAddOutput(frontCameraOutput) else { return }
            
            session.addOutput(frontCameraOutput)
        }
    }
    
    func displayFrontCamera() {
        guard let dualCameraView = self.dualCameraView,
              let mainCameraLayer = dualCameraView.mainCameraLayer,
              let secondaryCameraLayer = dualCameraView.secondaryCameraLayer,
              let session = self.session else { return }
        
        // Displays the Front Capture Device (camera) output in the Preview View.
        frontCaptureDevicePreviewLayer.session = session
        frontCaptureDevicePreviewLayer.videoGravity = .resizeAspectFill
        frontCaptureDevicePreviewLayer.connection?.videoOrientation = .portrait
        
        if isBackCameraMain {
            frontCaptureDevicePreviewLayer.frame.size = secondaryCameraLayer.frame.size
            secondaryCameraLayer.sublayers = nil
            secondaryCameraLayer.addSublayer(frontCaptureDevicePreviewLayer)
        } else {
            frontCaptureDevicePreviewLayer.frame.size = mainCameraLayer.frame.size
            mainCameraLayer.sublayers = nil
            mainCameraLayer.addSublayer(frontCaptureDevicePreviewLayer)
        }
    }
    
    func createMulticamSession() {
        self.session = AVCaptureMultiCamSession()
    }
    
    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in // userInitiated vs .background
            guard let session = self?.session else { return }
            
            session.startRunning()
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in // userInitiated vs .background
            guard let session = self?.session else { return }
            
            session.stopRunning()
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let dualCameraView = self?.dualCameraView else { return }
            
            dualCameraView.layer.sublayers = nil
            dualCameraView.backgroundColor = UIColor.black
        }
    }
    
    func takeFrontAndBackPhoto() {
        let photoSettings = AVCapturePhotoSettings()
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            backCameraOutput?.capturePhoto(with: photoSettings, delegate: self)
            frontCameraOutput?.capturePhoto(with: photoSettings, delegate: self)
        } else {
            presenter?.takePhotoFailure(error: "Error AVCapturePhotoSettings")
        }
    }
    
    func changeCameras() {
        isBackCameraMain.toggle()
        displayBackCamera()
        displayFrontCamera()
    }
    
}

// MARK: - AVCapturePhotoCapture Delegate

extension CameraManager: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {
            presenter?.takePhotoFailure(error: "")
            return
        }
        
        // Checks if the output came from the back camera or the front camera.
        if isBackCameraMain {
            if output == backCameraOutput {
                mainPhotoData = imageData
            } else {
                secondaryPhotoData = imageData
            }
        } else {
            if output == backCameraOutput {
                secondaryPhotoData = imageData
            } else {
                mainPhotoData = imageData
            }
        }
        
        guard let mainPhoto = mainPhotoData,
              let secondaryPhoto = secondaryPhotoData else {
            presenter?.takePhotoFailure(error: "")
            return
        }
        
        presenter?.takePhotoSuccess(mainPhoto: mainPhoto, secondaryPhoto: secondaryPhoto)
        
        mainPhotoData = nil
        secondaryPhotoData = nil
    }
    
}

// MARK: - CameraManagerToPresenterProtocol

extension CameraManager: CameraManagerToPresenterProtocol {}
