//
//  PhotoAlbumViewController.swift
//  Dual Camera
//
//  Created by Aitor Zubizarreta on 16/11/22.
//

import UIKit

class PhotoAlbumViewController: UIViewController {
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupNavBar()
    }
    
    private func setupView() {}
    
    private func setupNavBar() {
        title = "Photo Album"
        
        let closeBarButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeVC))
        navigationItem.rightBarButtonItems = [closeBarButton]
    }
    
    @objc private func closeVC() {
        self.dismiss(animated: true)
    }
    
}
