//
//  CamerasPresenter.swift
//  Dual Camera
//
//  Created by Aitor Zubizarreta on 2023-03-27.
//

import Foundation

final class CamerasPresenter {
    
    // MARK: - Properties (from CamerasPresenterProtocol)
    
    weak var view: CamerasViewProtocol?
    var cameraManager: CameraManagerProtocol
    
    init(cameraManager: CameraManagerProtocol) {
        self.cameraManager = cameraManager
    }
    
}

// MARK: - CamerasPresenterProtocol

extension CamerasPresenter: CamerasPresenterProtocol {
    
    func viewWillDisappear() {
        print("Presenter ViewWillDisappear")
        
        cameraManager.stopSession()
    }
    
    func checkCameraPermission() {
        cameraManager.hasCameraPermission { [weak self] granted in
            if granted {
                print("✅ Camera access : Granted")
                self?.view?.onCameraPermissionGranted()
            } else {
                print("❌ Camera access : Not Granted")
                self?.view?.onCameraPermissionNotGranted()
            }
        }
    }
    
    func checkMultiCamSupport() {
        if cameraManager.isMultiCamSupported() {
            print("✅ MultiCam : Supported")
            view?.onMultiCamSupported()
        } else {
            print("❌ MultiCam : Not Supported")
            view?.onMultiCamNotSupported()
        }
    }
    
    func setup(dualCameraView: DualCameraView) {
        cameraManager.setup(dualCameraView: dualCameraView)
    }
    
    func startSession() {
        cameraManager.startSession()
    }
    
    func stopSession() {
        cameraManager.stopSession()
    }
    
    func changeCameras() {
        cameraManager.changeCameras()
    }
    
    func takePhoto() {
        cameraManager.takeFrontAndBackPhoto()
    }
    
}