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
    var finalPhotoManager: FinalPhotoManagerProtocol
    var router: CamerasRouterProtocol?
    
    // MARK: - Methods
    
    init(cameraManager: CameraManagerProtocol, finalPhotoManager: FinalPhotoManagerProtocol) {
        self.cameraManager = cameraManager
        self.finalPhotoManager = finalPhotoManager
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

// MARK: - CamerasPresenterToCameraManagerProtocol

extension CamerasPresenter: CamerasPresenterToCameraManagerProtocol {
    
    func takePhotoSuccess(mainPhoto: Data, secondaryPhoto: Data) {
        finalPhotoManager.createFinalPhoto(mainPhotoData: mainPhoto, secondaryPhotoData: secondaryPhoto)
    }
    
    func takePhotoFailure(error: String) {
        print("\(error)")
    }
    
}

// MARK: - CamerasPresenterToFinalPhotoManagerProtocol

extension CamerasPresenter: CamerasPresenterToFinalPhotoManagerProtocol {
    
    func createFinalPhotoSuccess() {
        print("Presenter createFinalPhotoSuccess")
    }
    
    func createFinalPhotoFailure(errorDescription: String) {
        print("Presenter createFinalPhotoFailure. \(errorDescription)")
    }
    
    func saveFinalPhotoSuccess(finalImageData: Data) {
        print("Presenter saveFinalPhotoSuccess")
        view?.onTakePhotoSuccess(finalImageData: finalImageData)
    }
    
    func saveFinalPhotoFailure(errorDescription: String) {
        print("Presenter saveFinalPhotoFailure. \(errorDescription)")
    }
    
}
