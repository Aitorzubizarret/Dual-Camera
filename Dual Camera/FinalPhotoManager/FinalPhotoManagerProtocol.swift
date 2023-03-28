//
//  FinalPhotoManagerProtocol.swift
//  Dual Camera
//
//  Created by Aitor Zubizarreta on 2023-03-28.
//

import Foundation
import UIKit

protocol FinalPhotoManagerProtocol: AnyObject {
    
    func createFinalPhoto(mainPhotoData: Data, secondaryPhotoData: Data)
    func saveFinalPhotoInLibrary(image: CIImage)
    
}
