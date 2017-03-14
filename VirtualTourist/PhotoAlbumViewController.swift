//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Eric Wei on 2017-03-10.
//  Copyright © 2017 EricWei. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController{
    
    //UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
    
    @IBOutlet weak var noPhotosLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
  //  var managedObjectContext =
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        //collectionView.delegate = self
       // collectionView.dataSource = self
        automaticallyAdjustsScrollViewInsets = false
    }
    
    
    @IBAction func getNewCollection(_ sender: Any) {
        
    }
}

extension PhotoAlbumViewController: MKMapViewDelegate {
    
    
}
