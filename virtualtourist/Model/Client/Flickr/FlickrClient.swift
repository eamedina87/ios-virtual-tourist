//
//  FlickrClient.swift
//  virtualtourist
//
//  Created by Erick Medina on 15/9/18.
//  Copyright © 2018 Erick Medina. All rights reserved.
//

import Foundation

class FlickrClient:NSObject {
    
    private override init() {
        
    }
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = FlickrConstants.URL.APIScheme
        components.host = FlickrConstants.URL.APIHost
        components.path = FlickrConstants.URL.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    func getImagesForLocation(latitude:Double, longitude:Double, completionHandler: @escaping (_ result:Data?, _ error:NSError?) -> Void){
        if isLatitudeInRange(latitude) && isLongitudeInRange(longitude) {
            let methodParameters = [
                FlickrConstants.ParameterKeys.Method: FlickrConstants.ParameterValues.SearchMethod,
                FlickrConstants.ParameterKeys.APIKey: FlickrConstants.ParameterValues.APIKey,
                FlickrConstants.ParameterKeys.BoundingBox: getBboxString(latitude, longitude),
                FlickrConstants.ParameterKeys.SafeSearch: FlickrConstants.ParameterValues.UseSafeSearch,
                FlickrConstants.ParameterKeys.Extras: FlickrConstants.ParameterValues.MediumURL,
                FlickrConstants.ParameterKeys.Format: FlickrConstants.ParameterValues.ResponseFormat,
                FlickrConstants.ParameterKeys.PerPage: FlickrConstants.ParameterValues.PerPage,
                FlickrConstants.ParameterKeys.NoJSONCallback: FlickrConstants.ParameterValues.DisableJSONCallback
            ]
            displayImageFromFlickrBySearch(methodParameters as [String:AnyObject], completionHandler: completionHandler)
        }
    }
    
    
    private func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject], withPageNumber: Int? = 0,  completionHandler: @escaping (_ result: Data?, _ error: NSError?)->Void) {
        
        // add the page to the method's parameters
        var methodParametersWithPageNumber = methodParameters
        methodParametersWithPageNumber[FlickrConstants.ParameterKeys.Page] = withPageNumber as AnyObject?
        
        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)

                let error = NSError(domain: "displayImageFromFlickrBySearch", code: 1, userInfo:                [NSLocalizedDescriptionKey : error])
                completionHandler(nil, error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[FlickrConstants.ResponseKeys.Status] as? String, stat == FlickrConstants.ResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = parsedResult[FlickrConstants.ResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find key '\(FlickrConstants.ResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary[FlickrConstants.ResponseKeys.Photo] as? [[String: AnyObject]] else {
                displayError("Cannot find key '\(FlickrConstants.ResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            if photosArray.count == 0 {
                displayError("No Images Found")
                return
            } else {
                
                for photo in photosArray {
                    //let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                    //let pageNumber = withPageNumber ?? randomPhotoIndex
                    //let photoDictionary = photosArray[pageNumber] as [String: AnyObject]
                    //let photoTitle = photoDictionary[FlickrConstants.ResponseKeys.Title] as? String
                    /* GUARD: Does our photo have a key for 'url_m'? */
                    guard let imageUrlString = photo[FlickrConstants.ResponseKeys.MediumURL] as? String else {
                        displayError("Cannot find key '\(FlickrConstants.ResponseKeys.MediumURL)' in \(photo)")
                        return
                    }
                    
                    // if an image exists at the url, set the image and title
                    let imageURL = URL(string: imageUrlString)
                    if let imageData = try? Data(contentsOf: imageURL!) {
                        completionHandler(imageData, nil)
                    } else {
                        displayError("Image does not exist at \(imageURL)")
                    }
                }
            }
        }
        
        // start the task!
        task.resume()
    }
    
    
}
