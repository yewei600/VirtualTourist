//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Eric Wei on 2017-03-10.
//  Copyright © 2017 EricWei. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
//    func setCellImage(_ image: UIImage?){
//        DispatchQueue.main.async {
//            self.photoImageView.image = image
//            if self.photoImageView.image != nil {
//                self.activityIndicator.stopAnimating()
//            }
//        }
//    }
}
