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
    }
    
    func setupViewSize(maxWidth: CGFloat, maxHeight: CGFloat) {
        guard let mainCameraLayer = self.mainCameraLayer,
              let secondaryCameraLayer = self.secondaryCameraLayer else { return }
        
        // Main Camera.
        mainCameraLayer.frame = CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight)
        
        // Secondary Camera.
        let secondaryCameraLayerWidth: CGFloat = maxWidth/4
        let secondaryCameraLayerHeight: CGFloat = maxHeight/4
        let secondaryCameraLayerXPosition: CGFloat = maxWidth - secondaryCameraLayerWidth
        let secondaryCameraLayerYPosition: CGFloat = maxHeight - secondaryCameraLayerHeight
        
        secondaryCameraLayer.frame = CGRect(x: secondaryCameraLayerXPosition - 10,
                                            y: secondaryCameraLayerYPosition - 10,
                                            width: secondaryCameraLayerWidth,
                                            height: secondaryCameraLayerHeight)
        
        self.layer.addSublayer(mainCameraLayer)
        self.layer.addSublayer(secondaryCameraLayer)
    }
    
}
