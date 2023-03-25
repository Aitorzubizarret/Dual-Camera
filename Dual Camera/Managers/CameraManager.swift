//
//  CameraManager.swift
//  Dual Camera
//
//  Created by Aitor Zubizarreta on 1/11/22.
//

import UIKit
import AVFoundation
import Photos
import CoreImage

final class CameraManager: NSObject {
    
    // MARK: - Properties
    
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
    
    private var isBackCameraMain: Bool = true
    
    private var mainPhotoData: Data?
    private var secondaryPhotoData: Data?
    
    // MARK: - Methods
    
    private func createFinalPhoto(mainPhoto: Data, secondaryPhoto: Data) {
        
        // TODO: Check image size
        
        // Create two CIImages from received Data.
        guard let ciImageMainPhoto = CIImage(data: mainPhoto),
              let ciImageSecondaryPhoto = CIImage(data: secondaryPhoto) else { return }
        
        // Get size of main photo.
        let backgroundWidth = ciImageMainPhoto.extent.width
        let backgroundHeight = ciImageMainPhoto.extent.height
        
        // Scale secondary photo.
        let scaleTransform: CGAffineTransform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        let ciImageSecondaryPhotoScaled: CIImage = ciImageSecondaryPhoto.transformed(by: scaleTransform)
        
        // Calculate coordinates for the secondary photo.
        let x = backgroundWidth - (((backgroundWidth * 30) / 100) + 50)
        let y = backgroundHeight - (((backgroundHeight * 30) / 100) + 50)
        
        // Position secondary photo.
        let translateTransform: CGAffineTransform = CGAffineTransform(translationX: x, y: y)
        let ciImageSecondaryPhotoScaledTranslated: CIImage = ciImageSecondaryPhotoScaled.transformed(by: translateTransform)
        
        // Create blend filter.
        let blendFilter = CIFilter(name: "CISourceOverCompositing")
        blendFilter?.setValue(ciImageMainPhoto, forKey: kCIInputBackgroundImageKey)
        blendFilter?.setValue(ciImageSecondaryPhotoScaledTranslated, forKey: kCIInputImageKey)
        
        // Apply blend filter to create the ouput CIImage.
        guard let ciImageFinal = blendFilter?.outputImage else { return }
        
        // Create CoreImage context.
        let context = CIContext(options: nil)
        
        // CIImage -> CGImage.
        guard let cgiImageFinal = context.createCGImage(ciImageFinal, from: ciImageFinal.extent) else { return }
        
        // CGImage -> UIImage (with orientation).
        let uiimageFinal = UIImage(cgImage: cgiImageFinal, scale: 1.0, orientation: .right)
        
        saveUIImageAsImage(image: uiimageFinal)
    }
    
    private func saveUIImageAsImage(image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
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

extension CameraManager: CameraManagerProtocol {
    
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
    
    func isMultiCamSupported() -> Bool {
        return AVCaptureMultiCamSession.isMultiCamSupported
    }
    
    func setup(dualCameraView: DualCameraView) {
        // Setups the Front and Back Camera Preview Views.
        self.dualCameraView = dualCameraView
        
        createMulticamSession()
        
        configureBackCamera()
        displayBackCamera()
        
        configureFrontCamera()
        displayFrontCamera()
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
            print("NO Front Capture Device ready.")
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
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let session = self?.session else { return }
            
            session.startRunning()
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .background).async { [weak self] in
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
        }
    }
    
    func changeCameras() {
        isBackCameraMain.toggle()
        displayBackCamera()
        displayFrontCamera()
    }
    
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        if mainPhotoData == nil {
            mainPhotoData = imageData
        } else {
            secondaryPhotoData = imageData
            
            guard let mainPhoto = mainPhotoData,
                  let secondaryPhoto = secondaryPhotoData else { return }

            createFinalPhoto(mainPhoto: mainPhoto, secondaryPhoto: secondaryPhoto)

            mainPhotoData = nil
            secondaryPhotoData = nil
        }
    }
    
}
