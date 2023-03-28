//
//  CamerasProtocols.swift
//  Dual Camera
//
//  Created by Aitor Zubizarreta on 2023-03-27.
//

import Foundation
import UIKit

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
    var finalPhotoManager: FinalPhotoManagerProtocol { get set }
    var router: CamerasRouterProtocol? { get set }
    
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
    
    func takePhotoSuccess(mainPhoto: Data, secondaryPhoto: Data)
    func takePhotoFailure(error: String)
    
}

protocol CamerasPresenterToFinalPhotoManagerProtocol: AnyObject {
    
    func createFinalPhotoSuccess()
    func createFinalPhotoFailure(errorDescription: String)
    func saveFinalPhotoSuccess(finalImageData: Data)
    func saveFinalPhotoFailure(errorDescription: String)
    
}

// MARK: - Router

protocol CamerasRouterProtocol: AnyObject {
    
    static func createModule() -> UIViewController
    
}

// MARK: - CameraManager

protocol CameraManagerToPresenterProtocol: AnyObject {
    
    var presenter: CamerasPresenterToCameraManagerProtocol? { get set }
    
}

// MARK: - FinalPhotoManager

protocol FinalPhotoManagerToPresenterProtocol: AnyObject {
    
    var presenter: CamerasPresenterToFinalPhotoManagerProtocol? { get set }
    
}
