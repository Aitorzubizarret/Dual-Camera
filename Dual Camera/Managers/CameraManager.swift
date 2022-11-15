//
//  CameraManager.swift
//  Dual Camera
//
//  Created by Aitor Zubizarreta on 1/11/22.
//

import UIKit
import AVFoundation
import Photos

final class CameraManager: NSObject {
    
    // MARK: - Properties
    
    private var session: AVCaptureMultiCamSession? // AVCaptureSession?
    
    private var mainPreviewView: UIView?
    private var secondaryPreviewView: UIView?
    
    private var frontCaptureDevice: AVCaptureDevice?
    private var frontCaptureDevicePreviewLayer = AVCaptureVideoPreviewLayer()
    
    private var backCaptureDevice: AVCaptureDevice?
    private var backCaptureDevicePreviewLayer = AVCaptureVideoPreviewLayer()
    
    private var photoOutput: AVCapturePhotoOutput?
    
    // MARK: - Methods
    
    ///
    /// Creates the (MultiCam) session.
    ///
    private func createSession() {
        self.session = AVCaptureMultiCamSession()
    }
    
    ///
    /// Creates the Outputs and try to add to the session.
    ///
    private func createOutputsAndAddToSession() {
        // Create the Output.
        photoOutput = AVCapturePhotoOutput()
        
        guard let session = self.session,
              let photoOutput = self.photoOutput,
              session.canAddOutput(photoOutput) else { return }
        
        session.addOutput(photoOutput)
    }
    
    ///
    /// Discovers front devices, and if so adds the first front device (camera) input to the session.
    ///
    private func discoverFrontDeviceInputAndAddToSession() {
        // Checks if there is any Front capture device (camera) ready.
        let frontDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                     mediaType: .video,
                                                                     position: .front)
        
        let frontDevices = frontDiscoverySession.devices
        
        if frontDevices.isEmpty {
            print("NO Front Capture Device ready.")
        } else {
            self.frontCaptureDevice = frontDevices.first
            
            // Displays the Front Capture Device (camera) output in the Preview View.
            guard let secondaryPreviewView = self.secondaryPreviewView,
                  let frontCaptureDevice = self.frontCaptureDevice,
                  let frontCaptureDeviceInput = try? AVCaptureDeviceInput(device: frontCaptureDevice),
                  let session = self.session,
                  session.canAddInput(frontCaptureDeviceInput) else { return }
            
            session.addInput(frontCaptureDeviceInput)
            
            frontCaptureDevicePreviewLayer.session = session
            frontCaptureDevicePreviewLayer.frame.size = secondaryPreviewView.frame.size
            frontCaptureDevicePreviewLayer.videoGravity = .resizeAspect
            frontCaptureDevicePreviewLayer.connection?.videoOrientation = .portrait
            
            secondaryPreviewView.layer.addSublayer(frontCaptureDevicePreviewLayer)
        }
    }
    
    ///
    /// Discovers back devices, and if so adds the first back device (camera) input to the session.
    ///
    private func discoverBackDeviceInputAndAddToSession() {
        // Checks if there is any Back capture device (camera) ready.
        let backDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                    mediaType: .video,
                                                                    position: .back)
        
        let backDevices = backDiscoverySession.devices
        
        if backDevices.isEmpty {
            print("NO Back Capture Device ready.")
        } else {
            self.backCaptureDevice = backDevices.first
            
            // Displays the Back Capture Device (camera) output in the Preview View.
            guard let mainPreviewView = self.mainPreviewView,
                  let backCaptureDevice = self.backCaptureDevice,
                  let backCaptureDeviceInput = try? AVCaptureDeviceInput(device: backCaptureDevice),
                  let session = self.session,
                  session.canAddInput(backCaptureDeviceInput) else { return }
            
            session.addInput(backCaptureDeviceInput)
            
            backCaptureDevicePreviewLayer.session = session
            backCaptureDevicePreviewLayer.frame.size = mainPreviewView.frame.size
            backCaptureDevicePreviewLayer.videoGravity = .resizeAspect
            backCaptureDevicePreviewLayer.connection?.videoOrientation = .portrait
            
            mainPreviewView.layer.addSublayer(backCaptureDevicePreviewLayer)
        }
    }
    
}

extension CameraManager: CameraManagerProtocol {
    
    ///
    /// Checks if the App has Camera Permission.
    ///
    func hasCameraPermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            print("Camera auth permission : authorized")
            completion(true)
        case .notDetermined:
            print("Camera auth permission : notDetermined")
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        case .denied:
            print("Camera auth permission : denied")
            completion(false)
        case .restricted:
            print("Camera auth permission : restricted")
            completion(false)
        default: // For future status types.
            print("Camera auth permission : default")
            completion(false)
        }
    }
    
    ///
    /// Checks if the iPhone model supports multi camera function.
    ///
    func isMultiCamSupported() -> Bool {
        return AVCaptureMultiCamSession.isMultiCamSupported
    }
    
    func setup(mainPreviewView: UIView, secondaryPreviewView: UIView) {
        print("Start")
        
        // Setups the Front and Back Camera Preview Views.
        self.mainPreviewView = mainPreviewView
        self.secondaryPreviewView = secondaryPreviewView
        
        createSession()
        
        createOutputsAndAddToSession()
        
        discoverBackDeviceInputAndAddToSession()
        
        discoverFrontDeviceInputAndAddToSession()
    }
    
    func start() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let session = self?.session else { return }
            
            session.startRunning()
        }
    }
    
    ///
    /// Stops the session.
    ///
    func stop() {
        print("Stop")
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let session = self?.session else { return }
            
            session.stopRunning()
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let mainPreviewView = self?.mainPreviewView,
                  let secondaryPreviewView = self?.secondaryPreviewView else { return }
            
            mainPreviewView.layer.sublayers = nil
            mainPreviewView.backgroundColor = UIColor.black
            
            secondaryPreviewView.layer.sublayers = nil
            secondaryPreviewView.backgroundColor = UIColor.black
        }
    }
    
    func takeFrontAndBackPhoto() {
        let photoSettings = AVCapturePhotoSettings()
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoOutput?.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let photo = UIImage(data: imageData) else { return }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: photo)
        }, completionHandler: { success, error in
            if success {
                print("Success saving photo to gallery (didFinishProcessingPhoto)")
            } else if let error = error {
                print("Error didFinishProcessingPhoto saving photo to gallery")
            } else {
                // Save photo failed with no error
            }
        })
    }
    
}
