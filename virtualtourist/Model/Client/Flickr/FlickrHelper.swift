//
//  FlickrHelper.swift
//  virtualtourist
//
//  Created by Erick Medina on 16/9/18.
//  Copyright © 2018 Erick Medina. All rights reserved.
//

import Foundation

extension FlickrClient{
    
    func isLatitudeInRange(_ value:Double) -> Bool{
        let min = FlickrConstants.Search.SearchLatRange.0
        let max = FlickrConstants.Search.SearchLatRange.1
        return !(value < min || value > max)
    }
    
    func isLongitudeInRange(_ value:Double) -> Bool{
        let min = FlickrConstants.Search.SearchLonRange.0
        let max = FlickrConstants.Search.SearchLonRange.1
        return !(value < min || value > max)
    }
    
    func getBboxString(_ latitude:Double?, _ longitude:Double?) -> String {
        // ensure bbox is bounded by minimum and maximums
        if let latitude = latitude, let longitude = longitude {
            let minimumLon = max(longitude - FlickrConstants.Search.SearchBBoxHalfWidth, FlickrConstants.Search.SearchLonRange.0)
            let minimumLat = max(latitude - FlickrConstants.Search.SearchBBoxHalfHeight, FlickrConstants.Search.SearchLatRange.0)
            let maximumLon = min(longitude + FlickrConstants.Search.SearchBBoxHalfWidth, FlickrConstants.Search.SearchLonRange.1)
            let maximumLat = min(latitude + FlickrConstants.Search.SearchBBoxHalfHeight, FlickrConstants.Search.SearchLatRange.1)
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
        } else {
            return "0,0,0,0"
        }
    }
}
