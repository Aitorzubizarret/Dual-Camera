//
//  CamerasProtocols.swift
//  Dual Camera
//
//  Created by Aitor Zubizarreta on 2023-03-27.
//

import Foundation

protocol CamerasViewProtocol: AnyObject {
    
    var presenter: CamerasPresenterProtocol? { get set }
    
    func onCameraPermissionNotGranted()
    func onCameraPermissionGranted()
    func onMultiCamNotSupported()
    func onMultiCamSupported()
}

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
