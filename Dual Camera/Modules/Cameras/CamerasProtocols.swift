//
//  CamerasProtocols.swift
//  Dual Camera
//
//  Created by Aitor Zubizarreta on 2023-03-27.
//

import Foundation

// MARK: - View

protocol CamerasViewProtocol: AnyObject {
    
    var presenter: CamerasPresenterProtocol? { get set }
    
    func onCameraPermissionNotGranted()
    func onCameraPermissionGranted()
    func onMultiCamNotSupported()
    func onMultiCamSupported()
    
    func onTakePhotoSuccess(finalImageData: Data)
}

// MARK: - Presenter

protocol CamerasPresenterProtocol: AnyObject {
    
    var view: CamerasViewProtocol? { get set }
    var cameraManager: CameraManagerProtocol { get set }
    
    func viewWillDisappear()
    
    func checkCameraPermission()
    func checkMultiCamSupport()
    
    func setup(dualCameraView: DualCameraView)
    func startSession()
    func stopSession()
    
    func changeCameras()
    func takePhoto()
}

protocol CamerasPresenterToCameraManagerProtocol: AnyObject {
    
    func takePhotoSuccess(finalImageData: Data)
    func takePhotoFailure(error: String)
    
}

// MARK: - CameraManager

protocol CameraManagerToPresenterProtocol: AnyObject {
    
    var presenter: CamerasPresenterToCameraManagerProtocol? { get set }
    
}
