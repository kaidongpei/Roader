//
//  FollowingPathViewController.swift
//  myFireBase
//
//  Created by kaidong pei on 10/30/17.
//  Copyright © 2017 kaidong pei. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

var getID:String?
class FollowingPathViewController: UIViewController ,CLLocationManagerDelegate ,GMSMapViewDelegate{
    

    //var locationManager = CLLocationManager()
      let FollowPathDistanceDelta : CLLocationDistance = 20
      var path:  Path?
    var location: CLLocation?
    var currentLocation : CLLocation? {
        didSet {
            self.currentLocationDidSet()
        }
    }
    
    var isFinished : Bool {
        if let finishLocation = self.path?.track.last, let currentLocation = self.location {
            let distance = currentLocation.distance(from: finishLocation)
            return distance < FollowPathDistanceDelta
        }
        return false
    }
    
 
    var isAway : Bool {
        if let finishLocation = self.path?.track.first, let currentLocation = self.location {
            let distance = currentLocation.distance(from: finishLocation)
            return distance > FollowPathDistanceDelta
        }
        return false
    }

    @IBOutlet weak var btnLabel: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    var polyline = GMSPolyline()
    var gmsPath = GMSMutablePath()
    var GMSPathFolow = GMSMutablePath()
    var polylineFollow = GMSPolyline()
    var animatedMarker = GMSMarker()
    var isKeepFocus = true
    var track: Array<CLLocation> = []
    var storageRef : StorageReference?
    var databaseRef: DatabaseReference?
    var getId: String?
    var allPost: [getPost] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLocationService()
        animationImage()
        
        locationManager.delegate = self
        mapView.delegate = self
        getPostFunc()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if let track = path?.track{
            for loc in track{
                addRouteToPath(loc: loc)
            }
            
            createMarker(loc: track.first!, name: "starting_point")
            createMarker(loc: track.last!, name: "_flag_ending")
            
        }
        setMapBounds()
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        //print("bbbbbb")
        for i in allPost{
            let c = i
            //print(c)
            if marker.position.latitude == c.lco?.latitude && marker.position.longitude == c.lco?.longitude {
                // print("coming")
                let vc = storyboard?.instantiateViewController(withIdentifier: "showm") as! ShowMarkerViewController
                vc.getDesc = c.desc!
                vc.getMess = c.category!
                let url = URL(string: c.img!)
                let data = try? Data(contentsOf: url!)
                vc.getImg = UIImage(data: data!)
                self.present(vc, animated: true, completion: nil)
                
                
                
            }
        }
        return true
    }
    
    func getPostFunc(){
        databaseRef = Database.database().reference()
        databaseRef?.child("Paths").child(getId!).child("Posts").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            
            
            guard let val = snapshot.value as? NSDictionary else{return}
            
            
            for i in val{
                
                
                var c = i.value as! NSDictionary
                let cl = c["Location"] as! String
                let getDe = c["Description"] as! String
                let catg = c["Category"] as! String
                let imgaa = c["ImageURL"] as! String
                let ss = cl.components(separatedBy: CharacterSet(charactersIn: "<,>")).flatMap({
                    Double($0)
                })
                let c2 = CLLocationCoordinate2D(latitude: ss[0], longitude: ss[1])
                // print(c2)
                
                var getP = getPost(de: getDe, lc: c2, im: imgaa, cat: catg, id: i.key as! String)
                
                self.allPost.append(getP)
                
                
                let maker = GMSMarker()
                maker.position = c2
                maker.title = "My point"
                maker.icon = UIImage(named:"edit_selected")
                maker.isDraggable = true
                maker.map = self.mapView
                self.mapView.camera = GMSCameraPosition(target: c2, zoom: 15, bearing: 0, viewingAngle: 0)
                
                
                
                
                
            }
            
            //            self.userFN.text = value?["FirstName"] as? String ?? ""
            //            self.userLN.text = value?["LastName"] as? String ?? ""
            //            self.userPN.text = value?["PhoneNum"] as? String ?? ""
            //            self.userBB.text = value?["BankBalance"] as? String ?? ""
            //
            //            self.getImage(uid: userID!)
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    func setUpLocationService() {
        mapView?.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        animatedMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        animatedMarker.map = mapView
        
    }
    
    
    func addRouteToPathFollow(loc:CLLocation) {
        GMSPathFolow.add(loc.coordinate)
        polylineFollow.path = GMSPathFolow
        polylineFollow.strokeColor = UIColor(red:0.14, green:1.00, blue:0.00, alpha:1.0)
        polylineFollow.strokeWidth = 5
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)
        polylineFollow.map = mapView
        CATransaction.commit()
    }
    
    func addRouteToPath(loc: CLLocation) {
        gmsPath.add(loc.coordinate)
        polyline.path = gmsPath
        polyline.strokeColor = UIColor(red: 0.0/255.0, green: 255.0/255, blue:230.0/255, alpha: 1.0)
        polyline.strokeWidth = 5
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)
        polyline.map = mapView
        CATransaction.commit()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last{
            if track.isEmpty {
                createMarker(loc: loc, name: "starting_point")
            }
            animatedMarker.position = loc.coordinate
            if isKeepFocus == true && track.isEmpty == false{
                let camerPositon = GMSCameraPosition.camera(withTarget: loc.coordinate, zoom: 15, bearing: getBearingBetweenTwoPoints1(track.last!, point2: loc), viewingAngle: (mapView?.camera.viewingAngle)!)
                mapView?.animate(to: camerPositon)
            }
            track.append(loc)
            addRouteToPathFollow(loc: loc)
            currentLocation = loc
           
            
            let finishLocation = self.path?.track.first
            let finalPoint = self.path?.track.last
            
            let distance = Int((currentLocation?.distance(from: finishLocation!))!)
                print(distance)
            
            let finalDis = Int((currentLocation?.distance(from: finalPoint!))!)
            print(distance)
            
            
            if distance < 20 {
                
                let alertController = UIAlertController.init(title: "Message", message: "you are approaching the start point", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
                if distance == 0 {
                    //locationManager.stopUpdatingLocation()
                    btnLabel.setTitle("Start tracking", for: .normal)
                    btnLabel.backgroundColor = UIColor.red
                }
            }
            
            if finalDis == 0{
               // locationManager.stopUpdatingLocation()
                let alertController = UIAlertController.init(title: "Message", message: "you are reaching the end point", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
                locationManager.stopUpdatingLocation()
                btnLabel.setTitle("Done", for: .normal)
            }
            
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
    
   
    func createMarker(loc: CLLocation, name: String)  {
        
        let marker = GMSMarker()
        marker.position = loc.coordinate
        marker.title = "MyMarker"
        marker.map = mapView
        marker.isDraggable = true
        marker.icon = UIImage(named: name)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        self.mapView?.moveCamera(update)
        self.mapView?.setMinZoom(self.mapView!.minZoom, maxZoom: self.mapView!.maxZoom)
    }
    
    func currentLocationDidSet() {
        guard self.currentLocation!.timestamp.timeIntervalSinceNow < 10.0 else {
            return
        }
        animatedMarker.position = (self.currentLocation?.coordinate)!
        
        if isAway == false {
            print("Start")
        }
    }
    @IBAction func btnAction(_ sender: Any) {
        
        
        
        if btnLabel.titleLabel?.text == "Start tracking"{
           //locationManager.startUpdatingLocation()
            
        } else if btnLabel.titleLabel?.text == "Done"{
            
            self.dismiss(animated: true, completion: nil)
            let userId = Auth.auth().currentUser?.uid ?? ""
         Database.database().reference().child("Paths").child(getID!).child("Followers").updateChildValues([userId : "id"])
    }
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
    
    
    
    
    
}
