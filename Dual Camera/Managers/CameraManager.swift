//
//  CameraManager.swift
//  Dual Camera
//
//  Created by Aitor Zubizarreta on 1/11/22.
//

import UIKit
import AVFoundation

final class CameraManager: NSObject {
    
    // MARK: - Properties
    
    private var session: AVCaptureMultiCamSession? // AVCaptureSession?
    private var frontCameraPreviewView: UIView?
    private var backCameraPreviewView: UIView?
    private var frontCaptureDevice: AVCaptureDevice?
    private var backCaptureDevice: AVCaptureDevice?
    private var frontCaptureDevicePreviewLayer = AVCaptureVideoPreviewLayer()
    private var backCaptureDevicePreviewLayer = AVCaptureVideoPreviewLayer()
    
    // MARK: - Methods
    
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
    
    ///
    /// Setups the Front and Back Camera Preview Views.
    ///
    func setupCameraOutputs(frontCameraPreviewView: UIView, backCameraPreviewView: UIView) {
        self.frontCameraPreviewView = frontCameraPreviewView
        self.backCameraPreviewView = backCameraPreviewView
    }
    
    ///
    /// Setups the Camera Session.
    ///
    func setupCameraSession() {
        // Creates the MultiCam Capture Session.
        self.session = AVCaptureMultiCamSession()
    }
    
    ///
    /// Checks if there is any Front capture device (camera) ready.
    ///
    func isFrontCaptureDeviceReady() -> Bool {
        let frontDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                     mediaType: .video,
                                                                     position: .back)
        
        let frontDevices = frontDiscoverySession.devices
        
        if frontDevices.isEmpty {
            print("NO Front Capture Device ready.")
            return false
        } else {
            self.frontCaptureDevice = frontDevices.first
            return true
        }
    }
    
    ///
    /// Checks if there is any Back capture device (camera) ready.
    ///
    func isBackCaptureDeviceReady() -> Bool {
        let backDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                    mediaType: .video,
                                                                    position: .front)
        
        let backDevices = backDiscoverySession.devices
        
        if backDevices.isEmpty {
            print("NO Back Capture Device ready.")
            return false
        } else {
            self.backCaptureDevice = backDevices.first
            return true
        }
    }
    
    ///
    /// Displays the Front Capture Device (camera) output in the Preview View.
    ///
    func displayFrontCaptureDeviceOutput() {
        guard let frontCameraPreviewView = self.frontCameraPreviewView,
              let frontCaptureDevice = self.frontCaptureDevice,
              let frontCaptureDeviceInput = try? AVCaptureDeviceInput(device: frontCaptureDevice),
              let session = self.session,
              session.canAddInput(frontCaptureDeviceInput) else { return }
        
        session.addInput(frontCaptureDeviceInput)
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let session = self?.session else { return }
            
            session.startRunning()
        }
        
        frontCaptureDevicePreviewLayer.session = session
        frontCaptureDevicePreviewLayer.frame.size = frontCameraPreviewView.frame.size
        frontCaptureDevicePreviewLayer.videoGravity = .resizeAspect
        frontCaptureDevicePreviewLayer.connection?.videoOrientation = .portrait
        
        frontCameraPreviewView.layer.addSublayer(frontCaptureDevicePreviewLayer)
    }
    
    ///
    /// Displays the Back Capture Device (camera) output in the Preview View.
    ///
    func displayBackCaptureDeviceOutput() {
        guard let backCameraPreviewView = self.backCameraPreviewView,
              let backCaptureDevice = self.backCaptureDevice,
              let backCaptureDeviceInput = try? AVCaptureDeviceInput(device: backCaptureDevice),
              let session = self.session,
              session.canAddInput(backCaptureDeviceInput) else { return }
        
        session.addInput(backCaptureDeviceInput)
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let session = self?.session else { return }
            
            session.startRunning()
        }
        
        backCaptureDevicePreviewLayer.session = session
        backCaptureDevicePreviewLayer.frame.size = backCameraPreviewView.frame.size
        backCaptureDevicePreviewLayer.videoGravity = .resizeAspect
        backCaptureDevicePreviewLayer.connection?.videoOrientation = .portrait
        
        backCameraPreviewView.layer.addSublayer(backCaptureDevicePreviewLayer)
    }
    
}