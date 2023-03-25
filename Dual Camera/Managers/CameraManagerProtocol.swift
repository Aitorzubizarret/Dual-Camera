//
//  CameraManagerProtocol.swift
//  Dual Camera
//
//  Created by Aitor Zubizarreta on 1/11/22.
//

import UIKit
import AVFoundation

protocol CameraManagerProtocol {
    
    // MARK: - Properties
    
    var session: AVCaptureMultiCamSession? { get set }
    
    var dualCameraView: DualCameraView? { get set }
    
    var frontCaptureDevice: AVCaptureDevice? { get set }
    var frontCaptureDeviceInput: AVCaptureDeviceInput? { get set }
    
    var backCaptureDevice: AVCaptureDevice? { get set }
    var backCaptureDeviceInput: AVCaptureDeviceInput? { get set }
    
    var backCameraOutput: AVCapturePhotoOutput? { get set }
    var frontCameraOutput: AVCapturePhotoOutput? { get set }
    
    // MARK: - Methods
    
    func hasCameraPermission(completion: @escaping(Bool) -> Void)
    func isMultiCamSupported() -> Bool
    
    func setup(dualCameraView: DualCameraView)
    func configureBackCamera()
    func displayBackCamera()
    func configureFrontCamera()
    func displayFrontCamera()
    
    func createMulticamSession()
    func startSession()
    func stopSession()
    
    func takeFrontAndBackPhoto()
    func changeCameras()
}
