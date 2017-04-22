//
//  HotelViewController.swift
//  Hotelzzz
//
//  Created by Steve Johnson on 3/22/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import Foundation
import UIKit

//TODO: handle phone calls changes to status bar, handle rotation

/**
 @brief  The HotelViewController displays information about a single Hotel.
 @input  A hotelData model object describing a single hotel.
 @output
 @view
 @data
 */
class HotelViewController: UIViewController {
    
    var hotelData:Hotel?
    
    @IBOutlet var hotelNameLabel: UILabel!
    @IBOutlet weak var hotelImageView: UIImageView!
    @IBOutlet weak var hotelAddressLabel: UILabel!
    @IBOutlet weak var hotelPriceLabel: UILabel!

    override func viewDidLoad() {
        
        navigationItem.title = hotelData?.name // todo: remove this
        
        hotelImageView.contentMode = .scaleAspectFill
        
        // image border
        hotelImageView.layer.borderColor = UIColor.gray.cgColor;
        hotelImageView.layer.borderWidth = 2
        hotelImageView.layer.cornerRadius = 80
        hotelImageView.clipsToBounds = true
        
        if let hotel = hotelData {
            loadImage(hotel.imageURL)
            hotelNameLabel.text = hotel.name
            hotelAddressLabel.text = hotel.address
            hotelPriceLabel.text = hotel.formattedPrice
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    func loadImage(_ urlString:String?) {
        
        // load default image
        DispatchQueue.main.async { self.hotelImageView.image  = UIImage(named: "todo - add image name here") }
        
        
        guard let urlString = urlString else {return}
        
        let imageURL = URL(string: urlString)
        
        DispatchQueue.global().async {
            
            if let imageURL = imageURL {
                
                if let imageData = try? Data(contentsOf: imageURL) {
                    
                    DispatchQueue.main.async {
                        self.hotelImageView.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }
    
}
