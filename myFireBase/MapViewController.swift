//
//  mapViewController.swift
//  myFireBase
//
//  Created by kaidong pei on 10/18/17.
//  Copyright © 2017 kaidong pei. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class mapViewController: UIViewController,CLLocationManagerDelegate, GMSMapViewDelegate{
    
    var ref :  DatabaseReference?
    var storageRef = StorageReference()

    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var mapShow: GMSMapView!
    var locationManager = CLLocationManager()
    var polyline = GMSPolyline()
    var gmsPath = GMSMutablePath()
    var animatedMarker = GMSMarker()
    var isKeepFocus = true
    var track: Array<CLLocation> = []
    var myDataDictionary = [[String: Any]]()
    var distance = 0.0
    
    class path: NSObject{
        
        var pathID: String?
        var pathName: String?
        
        init(withsnap snapshot: DataSnapshot){
           
            //pathID = Dictionary[""] as String
        }
        
    }
//    func try() {
//        ref = Database.database().reference().child("path").childByAutoId()
//        path = path()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLocationService()
        animationImage()
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpLocationService() {
        mapShow?.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        animatedMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        animatedMarker.map = mapShow
    }
    
    func addRouteToPath(loc:CLLocation) {
        gmsPath.add(loc.coordinate)
        polyline.path = gmsPath
        polyline.strokeColor = UIColor.red
        polyline.strokeWidth = 5
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)
        polyline.map = mapShow
        CATransaction.commit()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last{
            if track.isEmpty {
                createMarker(loc: loc, name: "starting_point")
            }
            animatedMarker.position = loc.coordinate
            if isKeepFocus == true && track.isEmpty == false{
                let camerPositon = GMSCameraPosition.camera(withTarget: loc.coordinate, zoom: 15, bearing: getBearingBetweenTwoPoints1(track.last!, point2: loc), viewingAngle: (mapShow?.camera.viewingAngle)!)
                mapShow?.animate(to: camerPositon)
            }
            track.append(loc)
            //get distance
            let dis = gmsPath.length(of: .geodesic)
            addRouteToPath(loc: loc)
            var myDictionary = [String: Any]()
            myDictionary["data"] = String(describing: loc)
            myDataDictionary.append(myDictionary)
        }
    }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture {
            isKeepFocus = false
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
    }
    func createMarker(loc: CLLocation, name: String)  {
        
        let marker = GMSMarker()
        marker.position = loc.coordinate
        marker.title = "MyMarker"
        marker.map = mapShow
        marker.isDraggable = true
        marker.icon = UIImage(named: name)
    }
    
    func animationImage() {
        var imageArr : Array<UIImage> = []
        for i in 1...44
        {
            imageArr.append(UIImage(named : "Anim 2_\(i)")!)
        }
        animatedMarker.icon = UIImage.animatedImage(with: imageArr, duration: 3.0)
    }
    
    func setMapBounds() {
        let bounds = GMSCoordinateBounds(path: self.gmsPath)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 80.0)
        self.mapShow?.moveCamera(update)
        self.mapShow?.setMinZoom(self.mapShow!.minZoom, maxZoom: self.mapShow!.maxZoom)
    }
    
    func degreesToRadians(_ degrees: Double) -> Double { return degrees * Double.pi / 180.0 }
    func radiansToDegrees(_ radians: Double) -> Double { return radians * 180.0 / Double.pi }
    
    func getBearingBetweenTwoPoints1(_ point1 : CLLocation, point2 : CLLocation) -> Double {
        
        let lat1 = degreesToRadians(point1.coordinate.latitude)
        let lon1 = degreesToRadians(point1.coordinate.longitude)
        
        let lat2 = degreesToRadians(point2.coordinate.latitude)
        let lon2 = degreesToRadians(point2.coordinate.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansToDegrees(radiansBearing)
    }
    
    func createJSON(){
        if JSONSerialization.isValidJSONObject(myDataDictionary) {
            do {
                let rawData = try JSONSerialization.data(withJSONObject: myDataDictionary, options: .prettyPrinted)
                
                let data = rawData
                
                let date = Date()
                
                let createFile = storageRef.child("location/data\(date).JSON")
                
                _ = createFile.putData(data, metadata: nil, completion: { (metadata, error) in
                     print(error)
                    self.navigationController?.popViewController(animated: true)
                })
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func startTrack(_ sender: Any) {
        if btn.titleLabel?.text == "START" {
           btn.backgroundColor = UIColor.red
           btn.setTitle("STOP", for: .normal)
           locationManager.startUpdatingLocation()
            
            
        } else if btn.titleLabel?.text == "STOP" {
            btn.setTitle("START", for:.normal)
            btn.backgroundColor = UIColor.gray
            locationManager.stopUpdatingLocation()
            createMarker(loc: track.last!, name: "_flag_ending")
            setMapBounds()
            createJSON()
            self.dismiss(animated: true, completion: nil)
        }
      }
//    func create_path_table(){
//        let userID = Auth.auth().currentUser?.uid ?? ""
//        let pathDict = ["":""]
//        ref?.updateChildValues(pathDict, withCompletionBlock: { (error, ref) in
//            Database.database().reference().child("user").
//        })
//    }
    
}
