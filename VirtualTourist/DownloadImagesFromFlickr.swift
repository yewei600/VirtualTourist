//
//  DownloadImagesFromFlickr.swift
//  VirtualTourist
//
//  Created by Eric Wei on 2017-03-10.
//  Copyright © 2017 EricWei. All rights reserved.
//

import Foundation

class DownloadImagesFromFlickr {
    
    // MARK: Flickr API
    
    private func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject]) {
        
        //print(flickrURLFromParameters(methodParameters))
        // TODO: Make request to Flickr!
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        let task = session.dataTask(with: flickrURLFromParameters(methodParameters)){ (data,response,error) in
            
            func displayError(error: String) {
                print(error)
                performUIUpdatesOnMain {
//                    self.setUIEnabled(true)
//                    self.photoTitleLabel.text = "No photo returned. Try again."
//                    self.photoImageView.image = nil
                }
            }
            
            guard (error == nil) else{
                displayError(error: error as! String)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                displayError(error: "request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else{
                displayError(error: "No data was returned by the request!")
                return
            }
            
            let parsedResult: [String:AnyObject]!
            do{
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as!
                    [String:AnyObject]
            }catch{
                displayError(error: "Could not parse the data as JSON: '\(data)'")
                return
            }
            
            //did Flickr return an error?
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat ==
                Constants.FlickrResponseValues.OKStatus else {
                    displayError(error: "Flickr API returned an error. See error code and message in \(parsedResult)")
                    return
            }
            
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError(error: "Cannot find key '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            guard let numOfPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                displayError(error: "Cannot find number of pages")
                return
            }
            
            let pageLimit = min(numOfPages, 40)
            print("pageLimit is \(pageLimit)")
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            self.displayImageFromFlickrBySearch(methodParameters: methodParameters, withPageNumber: randomPage)
        }
        //start the task!
        task.resume()
    }
    
    func displayImageFromFlickrBySearch(methodParameters: [String:AnyObject], withPageNumber: Int) {
        
        var methodParametersWithPageNumber = methodParameters
        methodParametersWithPageNumber[Constants.FlickrParameterKeys.Page] = withPageNumber as AnyObject
        // TODO: Make request to Flickr!
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        let task = session.dataTask(with: flickrURLFromParameters(methodParameters)){ (data,response,error) in
            
            func displayError(error: String) {
                print(error)
                performUIUpdatesOnMain {
//                    self.setUIEnabled(true)
//                    self.photoTitleLabel.text = "No photo returned. Try again."
//                    self.photoImageView.image = nil
                }
            }
            
            guard (error == nil) else{
                displayError(error: error as! String)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                displayError(error: "request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else{
                displayError(error: "No data was returned by the request!")
                return
            }
            
            let parsedResult: [String:AnyObject]!
            do{
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as!
                    [String:AnyObject]
            }catch{
                displayError(error: "Could not parse the data as JSON: '\(data)'")
                return
            }
            
            //did Flickr return an error?
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat ==
                Constants.FlickrResponseValues.OKStatus else {
                    displayError(error: "Flickr API returned an error. See error code and message in \(parsedResult)")
                    return
            }
            
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError(error: "Cannot find key '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                displayError(error: "Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            if photosArray.count == 0 {
                displayError(error: "No photos found. Search Again.")
                return
            } else {
                let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
                let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
                
                /* GUARD: Does our photo have a key for 'url_m'? */
                guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                    displayError(error: "Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photosDictionary)")
                    return
                }
                
                // if an image exists at the url, set the image and title
                let imageURL = URL(string: imageUrlString)
                if let imageData = try? Data(contentsOf: imageURL!) {
                    performUIUpdatesOnMain {
//                        self.setUIEnabled(true)
//                        self.photoImageView.image = UIImage(data: imageData)
//                        self.photoTitleLabel.text = photoTitle ?? "(Untitled)"
                    }
                } else {
                    displayError(error: "Image does not exist at \(imageURL)")
                }
            }
        }
        //start the task!
        task.resume()
    }
    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(_ parameters: [String: AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    
    
}
