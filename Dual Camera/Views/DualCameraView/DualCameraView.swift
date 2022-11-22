//
//  DualCameraView.swift
//  Dual Camera
//
//  Created by Aitor Zubizarreta on 16/11/22.
//

import UIKit

final class DualCameraView: UIView {
    
    // MARK: - Properties
    
    var mainCameraLayer: CALayer?
    var secondaryCameraLayer: CALayer?
    private var secondaryCameraLayerOuterBorder: CALayer?
    
    // MARK: - Methods
    
    ///
    /// Inits the view from code.
    ///
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    ///
    /// Inits the view from XIB or Storyboard.
    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    private func setupView() {
        mainCameraLayer = CALayer()
        secondaryCameraLayer = CALayer()
        secondaryCameraLayerOuterBorder = CALayer()
    }
    
    func setupViewSize(maxWidth: CGFloat, maxHeight: CGFloat) {
        guard let mainCameraLayer = self.mainCameraLayer,
              let secondaryCameraLayer = self.secondaryCameraLayer,
              let secondaryCameraLayerOuterBorder = self.secondaryCameraLayerOuterBorder else { return }
        
        // Main Camera.
        mainCameraLayer.frame = CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight)
        
        // Secondary Camera.
        let secondaryCameraLayerWidth: CGFloat = maxWidth/4
        let secondaryCameraLayerHeight: CGFloat = maxHeight/4
        let secondaryCameraLayerXPosition: CGFloat = (maxWidth - secondaryCameraLayerWidth) - 10
        let secondaryCameraLayerYPosition: CGFloat = (maxHeight - secondaryCameraLayerHeight) - 10
        
        secondaryCameraLayer.frame = CGRect(x: secondaryCameraLayerXPosition,
                                            y: secondaryCameraLayerYPosition,
                                            width: secondaryCameraLayerWidth,
                                            height: secondaryCameraLayerHeight)
        secondaryCameraLayer.cornerRadius = 10
        secondaryCameraLayer.borderWidth = 1
        secondaryCameraLayer.borderColor = UIColor.black.cgColor
        secondaryCameraLayer.masksToBounds = true
        
        // Secondary Camera Outer Border Layer.
        secondaryCameraLayerOuterBorder.frame = CGRect(x: secondaryCameraLayerXPosition - 1,
                                                        y: secondaryCameraLayerYPosition - 1,
                                                        width: secondaryCameraLayerWidth + 2,
                                                        height: secondaryCameraLayerHeight + 2)
        secondaryCameraLayerOuterBorder.cornerRadius = 10
        secondaryCameraLayerOuterBorder.borderWidth = 1
        secondaryCameraLayerOuterBorder.borderColor = UIColor.white.cgColor
        secondaryCameraLayerOuterBorder.masksToBounds = true
        secondaryCameraLayerOuterBorder.addSublayer(secondaryCameraLayer)
        
        
        self.layer.addSublayer(mainCameraLayer)
        self.layer.addSublayer(secondaryCameraLayer)
        self.layer.addSublayer(secondaryCameraLayerOuterBorder)
    }
    
}
