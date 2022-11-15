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
    func setup(mainPreviewView: UIView, secondaryPreviewView: UIView)
    func start()
    func stop()
    func takeFrontAndBackPhoto()
}
