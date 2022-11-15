//
//  CameraManagerProtocol.swift
//  Dual Camera
//
//  Created by Aitor Zubizarreta on 1/11/22.
//

import UIKit
import AVFoundation

protocol CameraManagerProtocol {
    func hasCameraPermission(completion: @escaping(Bool) -> Void)
    func isMultiCamSupported() -> Bool
    func stop()
    func prepareCameras()
    func setupCameraOutputs(frontCameraPreviewView: UIView, backCameraPreviewView: UIView)
    func isFrontCaptureDeviceReady() -> Bool
    func isBackCaptureDeviceReady() -> Bool
    func displayFrontCaptureDeviceOutput()
    func displayBackCaptureDeviceOutput()
    func takeFrontAndBackPhoto()
}
