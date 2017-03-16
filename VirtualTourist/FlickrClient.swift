//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Eric Wei on 2017-03-10.
//  Copyright © 2017 EricWei. All rights reserved.
//

import Foundation

class FlickrClient {
    
    var methodParameters: [String:AnyObject] = [
        FlickrParameterKeys.APIKey: FlickrParameterValues.APIKey as AnyObject,
        FlickrParameterKeys.Method: FlickrParameterValues.SearchMethod as AnyObject,
        FlickrParameterKeys.Extras: FlickrParameterValues.MediumURL as AnyObject,
        FlickrParameterKeys.Format: FlickrParameterValues.ResponseFormat as AnyObject,
        FlickrParameterKeys.NoJSONCallback: FlickrParameterValues.DisableJSONCallback as AnyObject
    ]
    
    // MARK: Flickr API
    
    func getLocationPhotoPages(_ pin: Pin, completionHandler: @escaping (_ page: Int?, _ success: Bool, _ error: String?) -> Void) {
        
        print(flickrURLFromParameters(methodParameters))
        // TODO: Make request to Flickr!
        let session = URLSession.shared
        methodParameters[FlickrParameterKeys.Lat] = pin.lat as AnyObject?
        methodParameters[FlickrParameterKeys.Long] = pin.long as AnyObject?
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        let task = session.dataTask(with: flickrURLFromParameters(methodParameters)){ (data,response,error) in
            
            func sendError(error: String){
                print(error)
                completionHandler(nil,false,error)
            }
            
            guard (error == nil) else{
                sendError(error: error as! String)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                sendError(error: "request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else{
                sendError(error: "No data was returned by the request!")
                return
            }
            
            let parsedResult: [String:AnyObject]!
            do{
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as!
                    [String:AnyObject]
            }catch{
                sendError(error: "Could not parse the data as JSON: '\(data)'")
                return
            }
            
            //did Flickr return an error?
            guard let stat = parsedResult[FlickrResponseKeys.Status] as? String, stat ==
                FlickrResponseValues.OKStatus else {
                    sendError(error: "Flickr API returned an error. See error code and message in \(parsedResult)")
                    return
            }
            
            guard let photosDictionary = parsedResult[FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                sendError(error: "Cannot find key '\(FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            guard let numOfPages = photosDictionary[FlickrResponseKeys.Pages] as? Int else {
                sendError(error: "Cannot find number of pages")
                return
            }
            
            let pageLimit = min(numOfPages, 40)
            print("pageLimit is \(pageLimit)")
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            
            completionHandler(randomPage,true,nil)
        }
        //start the task!
        task.resume()
    }
    
    func getPagePhotos(_ pin: Pin, withPageNumber: Int, completionHandler: @escaping (_ photosURL:[String]?, _ photosData:[Data], _ success: Bool, _ error: String?) -> Void) {
        
        // TODO: Make request to Flickr!
        let session = URLSession.shared
        methodParameters[FlickrParameterKeys.Page] = withPageNumber as AnyObject?
        
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        let task = session.dataTask(with: flickrURLFromParameters(methodParameters)){ (data,response,error) in
            
            func sendError(error: String){
                print(error)
                // completion
            }
            
            guard (error == nil) else{
                sendError(error: error as! String)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                sendError(error: "request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else{
                sendError(error: "No data was returned by the request!")
                return
            }
            
            let parsedResult: [String:AnyObject]!
            do{
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as!
                    [String:AnyObject]
            }catch{
                sendError(error: "Could not parse the data as JSON: '\(data)'")
                return
            }
            
            //did Flickr return an error?
            guard let stat = parsedResult[FlickrResponseKeys.Status] as? String, stat ==
                FlickrResponseValues.OKStatus else {
                    sendError(error: "Flickr API returned an error. See error code and message in \(parsedResult)")
                    return
            }
            
            guard let photosDictionary = parsedResult[FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                sendError(error: "Cannot find key '\(FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            guard let total = photosDictionary[FlickrResponseKeys.Total] as? String else {
                sendError(error: "Cannot find key '\(FlickrResponseKeys.Total)' in \(parsedResult)")
                return
            }
            
            guard let photosArray = photosDictionary[FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                sendError(error: "Cannot find key '\(FlickrResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            //get 12 random photos
            var chosen = [Int]()
            var photosURL = [String]()
            var photosData = [Data]()
            let perPage = min(Int(total)!, 100)
            let numberOfPhotos = min(Int(total)!, 12)
            if numberOfPhotos > 0 {
                for _ in 0...numberOfPhotos-1 {
                    var random = Int(arc4random_uniform(UInt32(perPage)))
                    while chosen.contains(random) {
                        random = Int(arc4random_uniform(UInt32(perPage)))
                    }
                    chosen.append(random)
                    let photo = photosArray[random] as [String:AnyObject]
                    //saving the photo data and URL into arrays
                    if let photoUrl = photo[FlickrResponseKeys.MediumURL] as? String {
                        if let imageData = try? Data(contentsOf: URL(string: photoUrl)!) {
                            photosData.append(imageData)
                        }
                        photosURL.append(photoUrl)
                    }
                }
            }
            completionHandler(photosURL,photosData,true,nil)
        }
        //start the task!
        task.resume()
    }
    
    func getSinglePhoto(_ photoURL: String, completionHandler:(_ imageData: Data?, _ success: Bool) -> Void) {
        let url = URL(string: photoURL)
        if let imageData = try? Data(contentsOf: url!){
            completionHandler(imageData, true)
        } else {
            completionHandler(nil, false)
        }
    }
    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(_ parameters: [String: AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Flickr.APIScheme
        components.host = Flickr.APIHost
        components.path = Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
}
