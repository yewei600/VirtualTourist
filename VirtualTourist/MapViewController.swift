//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Eric Wei on 2017-03-10.
//  Copyright © 2017 EricWei. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var mapViewInEditState: Bool = false
    var bottomConstraint: NSObject!
    
    // var pins = [Pin]()
    var editMode = false
    // var managedObjectContext
    
    // MARK: lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.longPressAction(gestureRecognizer:)))
        mapView.addGestureRecognizer(longPress)
        
    }
    
    // MARK: Actions
    func longPressAction(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            print("long press detected 0")
            let touchPoint = gestureRecognizer.location(in: self.mapView)
            let newCoord: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            
            let newAnnotation = MKPointAnnotation()
            newAnnotation.coordinate = newCoord
            mapView.addAnnotation(newAnnotation)
        }
    }
    
    
    
    
    @IBAction func goToPhotoAlumbVC(_ sender: Any) {
        print("goToPhotoAlbumVC called")
        let controller = storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        navigationController!.pushViewController(controller, animated: true)
    }
    
    func animateMapViewConstraintChange() {
        if(!mapViewInEditState) {
            mapViewInEditState = true
            navigationItem.rightBarButtonItem?.title = "Done"
            //
            UIView.animate(withDuration: 100, animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            mapViewInEditState = false
            navigationItem.rightBarButtonItem?.title = "Edit"
            //
            UIView.animate(withDuration: 100, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    //Mark: Pin Editing
    override func setEditing(_ editing: Bool, animated: Bool) {
        <#code#>
    }
}

//MARK: MapView
extension MapViewController: MKMapViewDelegate {
    
    //Returns the view associated with the specified annotation object.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("view For called")
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = UIColor.red
            pinView!.animatesDrop = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("did select")
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        let photoAlbumViewController = storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        
        self.navigationController!.pushViewController(photoAlbumViewController, animated: true)
        
    }
    
}

