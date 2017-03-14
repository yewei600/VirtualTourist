//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Eric Wei on 2017-03-14.
//  Copyright © 2017 EricWei. All rights reserved.
//

import Foundation
import CoreData


public class Photo: NSManagedObject {

    convenience init(url: String, data: Data, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context){
            self.init(entity: ent, insertInto: context)
            self.imagePath = url
            self.imageData = data as NSData?
        } else{
            fatalError("Unable to find Photo Entity name!")
        }
    }
}
