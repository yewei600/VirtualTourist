//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Eric Wei on 2017-03-14.
//  Copyright © 2017 EricWei. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var imagePath: String?
    @NSManaged public var pin: Pin?

}
