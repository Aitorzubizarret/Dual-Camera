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
    
    private var session: AVCaptureSession? // AVCaptureMultiCamSession()
    private var mainCameraPreviewView: UIView?
    private var mainCaptureDevice: AVCaptureDevice?
    private var mainCaptureDevicePreviewLayer = AVCaptureVideoPreviewLayer()
    
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
    /// Setups the Camera Preview View.
    ///
    func setupCameraOutput(mainCameraPreviewView: UIView) {
        self.mainCameraPreviewView = mainCameraPreviewView
    }
    
    ///
    /// Setups the Camera Session.
    ///
    func setupCameraSession() {
        // Creates the MultiCam Capture Session.
        self.session = AVCaptureSession() // AVCaptureMultiCamSession()
    }
    
    ///
    /// Checks if there is any device (Camera) ready.
    ///
    func isMainCaptureDeviceReady() -> Bool {
        let discoverSessions = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera],
                                                                mediaType: .video,
                                                                position: .back)
        
        let devices = discoverSessions.devices
        
        if devices.isEmpty {
            print("No MainCaptureDevice ready")
            return false
        } else {
            self.mainCaptureDevice = devices.first
            return true
        }
    }
    
    ///
    /// Displays the main capture device (camera) output in the Preview View.
    ///
    func displayMainCaptureDeviceOutput() {
        guard let mainCameraPreviewView = self.mainCameraPreviewView,
              let mainCaptureDevice = self.mainCaptureDevice,
              let mainCaptureDeviceInput = try? AVCaptureDeviceInput(device: mainCaptureDevice),
              let session = self.session,
              session.canAddInput(mainCaptureDeviceInput) else { return }
        
        session.addInput(mainCaptureDeviceInput)
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let session = self?.session else { return }
            
            session.startRunning()
        }
        
        mainCaptureDevicePreviewLayer.session = session
        mainCaptureDevicePreviewLayer.frame.size = mainCameraPreviewView.frame.size
        mainCaptureDevicePreviewLayer.videoGravity = .resizeAspect
        mainCaptureDevicePreviewLayer.connection?.videoOrientation = .portrait
        
        mainCameraPreviewView.layer.addSublayer(mainCaptureDevicePreviewLayer)
    }
    
}
