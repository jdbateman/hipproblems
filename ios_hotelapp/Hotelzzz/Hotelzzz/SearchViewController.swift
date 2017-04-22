//
//  SearchViewController.swift
//  Hotelzzz
//
//  Created by Steve Johnson on 3/22/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

// todo: note to add activity indicator on search action in other view controller

import Foundation
import WebKit
import UIKit

let hotelDetailsSegueID = "hotel_details"
let sortPickerSegueID = "select_sort"

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY-mm-dd"
    return formatter
}()

private func jsonStringify(_ obj: [AnyHashable: Any]) -> String {
    let data = try! JSONSerialization.data(withJSONObject: obj, options: [])
    return String(data: data, encoding: .utf8)!
}


class SearchViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate, SortPickerDelegate, UIPopoverPresentationControllerDelegate {

    struct Search {
        let location: String
        let dateStart: Date
        let dateEnd: Date

        var asJSONString: String {
            return jsonStringify([
                "location": location,
                "dateStart": dateFormatter.string(from: dateStart),
                "dateEnd": dateFormatter.string(from: dateEnd)
            ])
        }
    }

    // todo: comment to describe these variables
    private var _searchToRun: Search?
    private var _sortOption: String? // todo: enum
    private var _selectedHotel: Hotel?
    private var _hotelsCount: Int = 0

    @IBOutlet weak var sortBarButtonItem: UIBarButtonItem!
    
    // MARK: - Actions
    
    @IBAction func sortAction(_ sender: Any) {
        presentSortPopoverViewController()
        print("TODO: remove this action")
    }
    
    @IBAction func filterAction(_ sender: Any) {
        
    }
    
    // MARK: - API
    
    /** 
     @brief Search for a hotel, filtering on the input parameters
     @discussion uses the runHotelSearch API endpoint.
     @param location - a human readable address
     @param dateStart - the inital date in the format "YYYY-MM-DD"
     @param dateEnd - the end date in the format "YYYY-MM-DD"
     */
    func search(location: String, dateStart: Date, dateEnd: Date) {
        _searchToRun = Search(location: location, dateStart: dateStart, dateEnd: dateEnd)
        self.webView.load(URLRequest(url: URL(string: "http://hipmunk.github.io/hipproblems/ios_hotelapp/")!))
    }
    
    func setSortOption(_ sortOption: String) {
        _sortOption = sortOption
        
        guard let sortOption = _sortOption else { fatalError("Tried to load the page without having a search to run") }
        
        self.webView.evaluateJavaScript("window.JSAPI.setHotelSort(\"\(sortOption)\")"){ (result, error) in
            if error != nil {
                print(error ?? "unknown error")
            } else {
                print("result = \(result)")
            }
        }

    }
    
    // MARK: - WKWebView

    lazy var webView: WKWebView = {
        let webView = WKWebView(frame: CGRect.zero, configuration: {
            let config = WKWebViewConfiguration()
            config.userContentController = {
                let userContentController = WKUserContentController()

                // DECLARE YOUR MESSAGE HANDLERS HERE
                userContentController.add(self, name: "API_READY")
                userContentController.add(self, name: "API_SELECT_SORT_OPTION")
                userContentController.add(self, name: "HOTEL_API_HOTEL_SELECTED")
                userContentController.add(self, name: "HOTEL_API_RESULTS_READY")

                return userContentController
            }()
            return config
        }())
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self

        self.view.addSubview(webView)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options: [], metrics: nil, views: ["webView": webView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView]|", options: [], metrics: nil, views: ["webView": webView]))
        return webView
    }()

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let alertController = UIAlertController(title: NSLocalizedString("Could not load page", comment: ""), message: NSLocalizedString("Looks like the server isn't running.", comment: ""), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Bummer", comment: ""), style: .default, handler: nil))
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        switch message.name {
            
        // API Requests

//        case "API_SELECT_SORT_OPTION":
//            
//            guard let sortOption = _sortOption else { fatalError("Tried to load the page without having a search to run") }
//            self.webView.evaluateJavaScript(
//                "window.JSAPI.setHotelSort(\(sortOption))",
//                completionHandler: nil)
            
        case "API_READY":
            
            // TODO- better error handling with error enum
            guard let searchToRun = _searchToRun else { fatalError("Tried to load the page without having a search to run") }
            self.webView.evaluateJavaScript(
                "window.JSAPI.runHotelSearch(\(searchToRun.asJSONString))",
                completionHandler: nil)
            
        // API Responses
            
        case "HOTEL_API_HOTEL_SELECTED":
                        
            _selectedHotel = Hotel(json:message.body as! [String : Any])
            performSegue(withIdentifier: hotelDetailsSegueID, sender: nil)
            
        case "HOTEL_API_RESULTS_READY":
            
            guard let jsonResponse = message.body as? [String:Any] else {return}
            guard let results = jsonResponse["results"] as? [[String:Any]] else {return}
            _hotelsCount = results.count
            print("hotelCount = \(results.count)")
            
            self.navigationItem.title = "\(_hotelsCount) hotels"
            
//        case "HOTEL_API_SEARCH_READY":
//            
//            print("\(message.body)")
//            
        default: break
        }
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == hotelDetailsSegueID {
            let controller = segue.destination as! HotelViewController
            controller.hotelData = self._selectedHotel
        }
//        else if segue.identifier == sortPickerSegueID {
//            let controller = segue.destination.childViewControllers[0] as! SortPickerViewController
//            controller.sortPickerDelegate = self
//        }
    }

    // todo: loading progress - both are KVO compliant
    //self.webView.estimatedProgress
    // .isLoading
    
    // MARK: - SortPickerDelegate
    
    func didSelectSortOption(sortOption: String) {
        setSortOption(sortOption)
    }
    
    // MARK: - Popover
    
    func presentSortPopoverViewController() {
        
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "SortPickerID") as! SortPickerViewController
        popoverContent.modalPresentationStyle = .popover
        popoverContent.sortPickerDelegate = self
        
        if let popover = popoverContent.popoverPresentationController {
            popover.barButtonItem = sortBarButtonItem
            popoverContent.preferredContentSize = CGSize(width: 200, height: 140)
            popover.delegate = self
            popover.permittedArrowDirections = .up
        }
        
        self.present(popoverContent, animated: true, completion: nil)
    }
}
