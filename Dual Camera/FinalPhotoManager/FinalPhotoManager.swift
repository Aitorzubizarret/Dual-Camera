//
//  FinalPhotoManager.swift
//  Dual Camera
//
//  Created by Aitor Zubizarreta on 2023-03-28.
//

import Foundation
import UIKit
import CoreImage
import Photos

final class FinalPhotoManager {
    
    // MARK: - Properties (from FinalPhotoManagerToPresenterProtocol)
    
    var presenter: CamerasPresenterToFinalPhotoManagerProtocol?
    
    // MARK: - Methods
    
    private func scale(image: CIImage, byPercentage percentage: CGFloat) -> CIImage {
        let scaleTransform: CGAffineTransform = CGAffineTransform(scaleX: percentage, y: percentage)
        return image.transformed(by: scaleTransform)
    }
    
    private func roundCorners(of image: CIImage, withRadius radius: CGFloat) -> CIImage? {
        // Create a round rectangle filter.
        let roundRectangleFilter = CIFilter(name: "CIRoundedRectangleGenerator")
        roundRectangleFilter?.setValue(CIVector(cgRect: image.extent), forKey: kCIInputExtentKey)
        roundRectangleFilter?.setValue(radius, forKey: kCIInputRadiusKey)
        
        guard let roundRectangleImage = roundRectangleFilter?.outputImage else { return nil }
        
        // Blend the created round rectangle with the image received.
        // The output image will be as the rounded rectangle.
        let blendFilter = CIFilter(name: "CISourceAtopCompositing")
        blendFilter?.setValue(roundRectangleImage, forKey: kCIInputBackgroundImageKey)
        blendFilter?.setValue(image, forKey: kCIInputImageKey)
        
        return blendFilter?.outputImage
    }
    
}

// MARK: - FinalPhotoManagerProtocol

extension FinalPhotoManager: FinalPhotoManagerProtocol {
    
    func createFinalPhoto(mainPhotoData: Data, secondaryPhotoData: Data) {
        // TODO: Check image size
        
        // Create two CIImages from received Data.
        guard let ciImageMainPhoto = CIImage(data: mainPhotoData),
              var ciImageSecondaryPhoto = CIImage(data: secondaryPhotoData) else { return }
        
        // Get size of main photo.
        let backgroundWidth = ciImageMainPhoto.extent.width
        let backgroundHeight = ciImageMainPhoto.extent.height
        
        // Scale secondary photo.
        ciImageSecondaryPhoto = scale(image: ciImageSecondaryPhoto, byPercentage: 0.3)
        
        // Round the corners of the secondary photo.
        if let ciImageSecondaryPhotoRounded = roundCorners(of: ciImageSecondaryPhoto, withRadius: 20) {
            ciImageSecondaryPhoto = ciImageSecondaryPhotoRounded
        }
        
        // Calculate coordinates for the secondary photo.
        let x = backgroundWidth - (((backgroundWidth * 30) / 100) + 50)
        let y = backgroundHeight - (((backgroundHeight * 30) / 100) + 50)
        
        // Position secondary photo.
        let translateTransform: CGAffineTransform = CGAffineTransform(translationX: x, y: y)
        ciImageSecondaryPhoto = ciImageSecondaryPhoto.transformed(by: translateTransform)
        
        // Create blend filter.
        let blendFilter = CIFilter(name: "CISourceOverCompositing")
        blendFilter?.setValue(ciImageMainPhoto, forKey: kCIInputBackgroundImageKey)
        blendFilter?.setValue(ciImageSecondaryPhoto, forKey: kCIInputImageKey)
        
        // Apply blend filter to create the ouput CIImage.
        guard let ciImageFinal = blendFilter?.outputImage else { return }
        
        saveFinalPhotoInLibrary(image: ciImageFinal)
        presenter?.createFinalPhotoSuccess()
    }
    
    func saveFinalPhotoInLibrary(image: CIImage) {
        // Create CoreImage context.
        let context = CIContext(options: nil)
        
        // CIImage -> CGImage.
        guard let cgiImageFinal = context.createCGImage(image, from: image.extent) else { return }
        
        guard let imageData: Data = UIImage(cgImage: cgiImageFinal, scale: 1.0, orientation: .right).jpegData(compressionQuality: 1.0) else { return }
        
        let library = PHPhotoLibrary.shared()
        library.performChanges ({
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, data: imageData, options: nil)
        }, completionHandler: { success, error in
            if success {
                print("✅ Success saving the photo in Photo Gallery.")
                
                DispatchQueue.main.async { [weak self] in
                    self?.presenter?.saveFinalPhotoSuccess(finalImageData: imageData)
                }
            } else if let error = error {
                print("❌ Error saving the photo in Photo Gallery. (didFinishProcessingPhoto) Error:  \(error)")
                DispatchQueue.main.async { [weak self] in
                    self?.presenter?.saveFinalPhotoFailure(errorDescription: "Error saving the photo in Photo Gallery. \(error)")
                }
            } else {
                print("❌ Error saving the photo in Photo Gallery. (didFinishProcessingPhoto)")
                DispatchQueue.main.async { [weak self] in
                    self?.presenter?.saveFinalPhotoFailure(errorDescription: "Error saving the photo in Photo Gallery.")
                }
            }
        })
    }
    
}

// MARK: -

extension FinalPhotoManager: FinalPhotoManagerToPresenterProtocol {}
