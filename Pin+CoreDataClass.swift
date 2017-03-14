//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Eric Wei on 2017-03-14.
//  Copyright © 2017 EricWei. All rights reserved.
//

import Foundation
import CoreData
import MapKit

public class Pin: NSManagedObject {
    
    convenience init(coordinate: CLLocationCoordinate2D, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context){
            self.init(entity: ent, insertInto: context)
            self.lat = coordinate.latitude as Double
            self.long = coordinate.longitude as Double!
        }else{
            fatalError("Unable to find Pin Entity name!")
        }
    }
}
