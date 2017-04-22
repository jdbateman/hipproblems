//
//  Hotel.swift
//  Hotelzzz
//
//  Created by john bateman on 4/21/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import Foundation

/**
 @brief Hotel is a model class describing a single hotel.
 @input The model can be initialized with a json dictionary returned in the HOTEL_API_RESULTS_READY response.
 */
class Hotel {
    
    var price: Double?
    var id: Int?
    var name: String?
    var imageURL: String?
    var address: String?
    
    init(json: [String: Any]) {
        
        guard let result = json["result"] as? [String:Any] else {return}
        guard let hotel = result["hotel"] as? [String:Any] else {return}
        
        if let price = result["price"] as? Double {
            self.price = price as Double
        }
        
        if let id = hotel["id"] {
            self.id = id as? Int
        }
        
        if let name = hotel["name"] {
            self.name = name as? String
        }
        
        if let imageURL = hotel["imageURL"] {
            self.imageURL = imageURL as? String
        }
        
        if let address = hotel["address"] {
            self.address = address as? String
        }
    }
    
    /** Return the price formatted in the local currency. */
    var formattedPrice: String {
        guard let price = price else {return "unknown"}
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let formattedString = formatter.string(from: price as NSNumber) {
            return formattedString
        }
        return "unknown"
    }
}
