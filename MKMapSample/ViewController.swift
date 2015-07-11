//
//  ViewController.swift
//  MKMapSample
//
//  Created by Ziyang Tan on 7/10/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var mapPolyline: MKPolyline!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(37.4038194,-122.081267), 100000, 100000)
        mapView.setRegion(region, animated:true)
                
        directionAPITest()
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let routeLineRenderer = MKPolylineRenderer(polyline: mapPolyline)
        routeLineRenderer.strokeColor = UIColor.redColor()
        routeLineRenderer.lineWidth = 5
        return routeLineRenderer
    }
    
    func directionAPITest() {
        
        let directionURL = "https://maps.googleapis.com/maps/api/directions/json?origin=sanfrancisco&destination=sanjose&key=YOUR_API_KEY"
        let request = NSURLRequest(URL: NSURL(string:directionURL)!)
        let session = NSURLSession.sharedSession()
        session.dataTaskWithRequest(request,
            completionHandler: {(data: NSData!, response: NSURLResponse!, error: NSError!) in
                
                if error == nil {
                    let object = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as! NSDictionary
                    
                    let routes = object["routes"] as! [NSDictionary]
                    for route in routes {
                        let overviewPolyline = route["overview_polyline"] as! NSDictionary
                        let points = overviewPolyline["points"] as! String
                        self.mapPolyline = self.polyLineWithEncodedString(points)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.mapView.addOverlay(self.mapPolyline)
                        }
                    }
                }
                else {
                    println("Direction API error")
                }
                
        }).resume()
    }
    
    func polyLineWithEncodedString(encodedString: String) -> MKPolyline {
        let bytes = (encodedString as NSString).UTF8String
        let length = encodedString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        var idx: Int = 0
        
        var count = length / 4
        var coords = UnsafeMutablePointer<CLLocationCoordinate2D>.alloc(count)
        var coordIdx: Int = 0
        
        var latitude: Double = 0
        var longitude: Double = 0
        
        while (idx < length) {
            var byte = 0
            var res = 0
            var shift = 0
            
            do {
                byte = bytes[idx++] - 0x3F
                res |= (byte & 0x1F) << shift
                shift += 5
            } while (byte >= 0x20)
            
            let deltaLat = ((res & 1) != 0x0 ? ~(res >> 1) : (res >> 1))
            latitude += Double(deltaLat)
            
            shift = 0
            res = 0
            
            do {
                byte = bytes[idx++] - 0x3F
                res |= (byte & 0x1F) << shift
                shift += 5
            } while (byte >= 0x20)
            
            let deltaLon = ((res & 1) != 0x0 ? ~(res >> 1) : (res >> 1))
            longitude += Double(deltaLon)
            
            let finalLat: Double = latitude * 1E-5
            let finalLon: Double = longitude * 1E-5
            
            let coord = CLLocationCoordinate2DMake(finalLat, finalLon)
            coords[coordIdx++] = coord
            
            if coordIdx == count {
                let newCount = count + 10
                let temp = coords
                coords.dealloc(count)
                coords = UnsafeMutablePointer<CLLocationCoordinate2D>.alloc(newCount)
                for index in 0..<count {
                    coords[index] = temp[index]
                }
                temp.destroy()
                count = newCount
            }
            
        }
    
        let polyLine = MKPolyline(coordinates: coords, count: coordIdx)
        coords.destroy()

        return polyLine
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

