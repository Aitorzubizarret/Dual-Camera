//
//  CamerasRouter.swift
//  Dual Camera
//
//  Created by Aitor Zubizarreta on 2023-03-28.
//

import Foundation
import UIKit

final class CamerasRouter {}

extension CamerasRouter: CamerasRouterProtocol {
    
    static func createModule() -> UIViewController {
        // Camera Manager.
        let cameraManager: CameraManagerProtocol & CameraManagerToPresenterProtocol = CameraManager()
        
        // Camera Presenter.
        let presenter: CamerasPresenterProtocol & CamerasPresenterToCameraManagerProtocol = CamerasPresenter(cameraManager: cameraManager)
        
        // Camera Router.
        let router: CamerasRouterProtocol = CamerasRouter()
        
        // View Controller.
        let camerasVC = CamerasViewController(presenter: presenter)
        
        // Dependency Injection.
        presenter.view = camerasVC
        presenter.router = router
        cameraManager.presenter = presenter
        
        return camerasVC
    }
    
}
