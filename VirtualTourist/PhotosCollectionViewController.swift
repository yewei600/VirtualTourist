//
//  PhotosCollectionViewController.swift
//  VirtualTourist
//
//  Created by Eric Wei on 2017-03-10.
//  Copyright © 2017 EricWei. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotosCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MKMapViewDelegate{
    
    @IBOutlet weak var noPhotosLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    //MARK: properties
    var coreDataStack: CoreDataStack!
    var pin: Pin!
    var coordinates: CLLocationCoordinate2D!
    var lat: Double!
    var long: Double!
    var photos: [Photo]!
    var downloadCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        automaticallyAdjustsScrollViewInsets = false
        noPhotosLabel.isHidden = true
        //get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        coreDataStack = delegate.stack
        
        setUpMap()
        getPinPhotos()
        setUpViewCells()
    }
    
    // MARK: collection view methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "picCell", for: indexPath) as! PhotoCollectionViewCell
        let photo = photos[indexPath.item]
        //temp Image
        cell.setCellImage(nil)
        
        if let imageData = photo.imageData {
            cell.setCellImage(UIImage(data: imageData as Data))
        } else {
            //get the photo from Flickr
            DispatchQueue.global().async {
                FlickrClient.sharedInstance().getSinglePhoto(photo.imagePath!, completionHandler: { (data, success) in
                    if success {
                        DispatchQueue.main.async {
                            cell.setCellImage(UIImage(data: data!))
                            photo.imageData = data as NSData?
                            self.coreDataStack.save()
                        }
                    }
                })
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //delete photo
        let index = indexPath.row
        let photo = photos[index]
        if photo.imageData != nil {
            //delete photo from core data
            coreDataStack.context.delete(photo)
            coreDataStack.save()
            photos.remove(at: index)
            collectionView.deleteItems(at: [indexPath])
        }
    }
    
    // MARK: helper methods
    @IBAction func getNewCollection(_ sender: Any) {
        //delete all current photos for the pin
        for photo in photos {
            coreDataStack.context.delete(photo)
            coreDataStack.save()
        }
        newCollectionButton.isEnabled = false
        noPhotosLabel.isHidden = true
        photos.removeAll()
        
        getFlickrPhotos { (success) in
            if success{
                self.collectionView.reloadData()
                print("finished reloading new photos")
            }
        }
    }
    
    func getFlickrPhotos(completionHandler: @escaping (_ success: Bool) -> Void) {
        FlickrClient.sharedInstance().getLocationPhotoPages(pin) { (pageNumber, success, error) in
            if success {
                FlickrClient.sharedInstance().getPagePhotos(self.pin, withPageNumber: pageNumber!, completionHandler: { (photosURL, photosData, success, error) in
                    if success {
                        for url in photosURL! {
                            for data in photosData {
                                let photo = Photo(url: url, data: data, context: self.coreDataStack.context)
                                photo.pin = self.pin
                            }
                        }
                        DispatchQueue.main.async {
                            //should be called on the main thread.
                            self.coreDataStack.save()
                            completionHandler(true)
                        }
                    } else {
                        print("error downloading photos from Flickr!")
                    }
                })
            } else {
                print("error getting random photo page from Flickr!")
            }
        }
    }
    
    func getPinPhotos() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Photo")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        if let fetchResults = try? coreDataStack.context.fetch(fetchRequest) as! [Photo] {
            photos = fetchResults
            print("got \(photos.count) photos from core data!!!")
            if photos.count == 0 {
                noPhotosLabel.isHidden = false
                newCollectionButton.isEnabled = false
            }
        } else {
            print("error getting photos from core data")
        }
    }
    
    func setUpMap() {
        let annotation = MKPointAnnotation()
        let regionRadius: CLLocationDistance = 10000
        annotation.coordinate = coordinates
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinates, regionRadius * 2.0, regionRadius * 1.0)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.addAnnotation(annotation)
    }
    
    func setUpViewCells() {
        let space: CGFloat = 3.0
        let dimension = (self.view.frame.size.width - (2*space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = 0.1
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
}
