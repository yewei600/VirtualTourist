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
    
    // MARK: properties
    @IBOutlet weak var mapView: MKMapView!
    var editLabel: UILabel!
    var bottomConstraint: NSObject!
    var coreDataStack: CoreDataStack!
    
    // MARK: lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.longPressAddPin(gestureRecognizer:)))
        mapView.addGestureRecognizer(longPress)
        mapView.delegate = self
        
        //get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        coreDataStack = delegate.stack
        
        //the edit UILabel setup
        navigationItem.rightBarButtonItem = editButtonItem
        editLabel = UILabel(frame: editLabelFrameForSize(view.frame.size))
        editLabel.backgroundColor = UIColor.red
        editLabel.textColor = UIColor.white
        editLabel.textAlignment = NSTextAlignment.center
        editLabel.text = "Tap Pins to Delete"
        self.view.addSubview(editLabel)
        
        //load annotations
        loadAnnotations()
    }
    
    // MARK: Helper Functions
    func longPressAddPin(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            print("long press detected 0")
            let touchPoint = gestureRecognizer.location(in: self.mapView)
            let newCoord: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            
            //add pin to core data
            let newPin = Pin(coordinate: newCoord, context: coreDataStack.context)
            //add pin annotation to map
            let newAnnotation = MKPointAnnotation()
            newAnnotation.coordinate = newCoord
            mapView.addAnnotation(newAnnotation)
        }
        coreDataStack.save()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        print("setEditing called")
        super.setEditing(editing, animated: animated)
        
        let yOffset: CGFloat = 70 * (editing ? -1 : 1)
        
        if (animated) {
            UIView.animate(withDuration: 0.15, animations: {
                self.mapView.frame = self.mapView.frame.offsetBy(dx: 0, dy: yOffset)
                self.editLabel.frame = self.editLabel.frame.offsetBy(dx: 0, dy: yOffset)
            })
        } else {
            mapView.frame = mapView.frame.offsetBy(dx: 0, dy: yOffset)
            editLabel.frame = editLabel.frame.offsetBy(dx: 0, dy: yOffset)
        }
    }
    
    func editLabelFrameForSize(_ size: CGSize) -> CGRect {
        let editingShift: CGFloat = 70 * (isEditing ? -1 : 0)
        let labelRect = CGRect(x: 0, y: size.height + editingShift, width: size.width, height: 70)
        return labelRect
    }
    
    func mapFrameForSize(_ size: CGSize) -> CGRect {
        let editingShift: CGFloat = 70 * (isEditing ? -1 : 0)
        let labelRect = CGRect(x: 0, y: editingShift, width: size.width, height: size.height)
        return labelRect
    }
    
    func loadAnnotations() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        if let pins = try? coreDataStack.context.fetch(fetchRequest) as! [Pin] {
            var pinAnnotations = [MKPointAnnotation]()
            for pin in pins {
                let newAnnotation = MKPointAnnotation()
                newAnnotation.coordinate.latitude = CLLocationDegrees(pin.lat)
                newAnnotation.coordinate.longitude = CLLocationDegrees(pin.long)
                pinAnnotations.append(newAnnotation)
            }
            print("# of pins == \(pinAnnotations.count)")
            //add annotations to the map
            mapView.addAnnotations(pinAnnotations)
        }
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
        //if let pin = getSelecte
        var pin: Pin!
        do {
            let pinAnnotation = view.annotation as! MKPointAnnotation
            
        }
        //        guard !self.isEditing else {
        //            mapView.removeAnnotation(view.annotation!)
        //
        //        }
        
        let photoAlbumViewController = storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        self.navigationController!.pushViewController(photoAlbumViewController, animated: true)
    }
}

