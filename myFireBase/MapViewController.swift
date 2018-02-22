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

class MapViewController: UIViewController,CLLocationManagerDelegate, GMSMapViewDelegate ,passPost{
    
    
    
   

    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var mapShow: GMSMapView!
    @IBOutlet weak var distanceShow: UILabel!
    @IBOutlet weak var timeShow: UILabel!
    
    
    var locationManager = CLLocationManager()
    var polyline = GMSPolyline()
    var gmsPath = GMSMutablePath()
    var animatedMarker = GMSMarker()
    var isKeepFocus = true
    var distance = 0.0
    var path: Path?
    var timer: Timer?
    var time: (Int, Int)?
    var counter = 0
    var seconds = 0
    var databaseRef: DatabaseReference?
    var showlat: String?
    var showLong:String?
    var currentCoor: CLLocation?
    //var post1: Post?
    var postList:[Post] = []
    
    
    var mapBackgroundOverlayer1 = GMSGroundOverlay()
    var mapBackgroundOverlayer2 = GMSGroundOverlay()
    var mapBackgroundOverlayer3 = GMSGroundOverlay()
    var img = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Make a path"
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationItem.leftBarButtonItem = nil;
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton;
        setupNavigationWithColor(UIColor.black)
        setUpLocationServices()
        start_trip()
        
        
        animationImage()
//        if post1?.lco != nil {
//            createMarker(loc: currentCoor!, name: "edit_selected")
//            
//        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func img(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected{
            showDarkBackgroudOnMap()
            mapShow.mapType = .none
        } else {
            clearMapViewBackground()
            mapShow.mapType = .hybrid
        }
    }

    
    
    func start_trip() {
        databaseRef =  Database.database().reference().child("Paths").childByAutoId()
        path = Path()
        path?.pathID = databaseRef?.key
        ManagePath.addInitialPath(pathid: (path?.pathID!)!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setupNavigationWithColor(_ color: UIColor) {
        let font = UIFont.boldSystemFont(ofSize: 20);
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : color, NSAttributedStringKey.font : font as Any]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = color
    }
    
    func setUpLocationServices(){
        mapShow.mapType = .hybrid
        locationManager.delegate = self
        mapShow.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        animatedMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        animatedMarker.map = mapShow
        locationManager.startUpdatingHeading()
        startTimer()
    }
    
    func addRouteToPath(loc:CLLocation) {
        gmsPath.add(loc.coordinate)
        polyline.path = gmsPath
        self.polyline.strokeColor = UIColor(red: 0.0/255.0, green: 255.0/255, blue:230.0/255, alpha: 1.0)
        polyline.zIndex = 10
        polyline.strokeWidth = 5
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)
        polyline.map = mapShow
        CATransaction.commit()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last{
                        if (path?.track.isEmpty)! {
                createMarker(loc: loc, name: "starting_point")
            }
            animatedMarker.position = loc.coordinate
            if isKeepFocus == true && path?.track.isEmpty == false{
                let camerPositon = GMSCameraPosition.camera(withTarget: loc.coordinate, zoom: 15, bearing: getBearingBetweenTwoPoints1((path?.track.last!)!, point2: loc), viewingAngle: (mapShow?.camera.viewingAngle)!)
                mapShow?.animate(to: camerPositon)
            }
            path?.track.append(loc)
            //get distance
            distance = gmsPath.length(of: .geodesic)
            let length = distance / 1000
            distanceShow.text = String(format: "%.2f", length) + " KM"
            showlat = String(loc.coordinate.latitude)
            showLong = String(loc.coordinate.longitude)
            addRouteToPath(loc: loc)
            currentCoor = loc
            
        }
        //print(currentCoor)
    }
    
    func startTimer(){
        locationManager.startUpdatingLocation()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(counterMe), userInfo: nil, repeats: true)
    }
    @objc func counterMe() {
        seconds += 1
        time = secondsToMinutesSeconds(seconds: seconds)
        path?.time = String(format: "%02d", time!.0) + ":" + String(format: "%02d", time!.1)
        self.timeShow.text = String(format: "%02d", time!.0) + ":" + String(format: "%02d", time!.1) + " Time" 
        
    }
    func secondsToMinutesSeconds (seconds : Int) -> (Int, Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture {
            isKeepFocus = false
        }
    }
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print(error.localizedDescription)
//    }
    
   
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
    
    func createPath(){
        if let saveMap = self.storyboard?.instantiateViewController(withIdentifier: "SavePathViewController")as? SavePathViewController{
                        saveMap.path = self.path
                        saveMap.getKm = distanceShow.text
                        saveMap.getTime = timeShow.text
                        saveMap.getPostList = postList
                        self.navigationController?.pushViewController(saveMap, animated: true)
                
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy < 0 {
            return
        }
        let megnathead = CGFloat(FTMathCalculations.DegreesToRadians(newHeading.magneticHeading))
        //print(CGAffineTransform(rotationAngle: -megnathead))
        img.transform = CGAffineTransform(rotationAngle: -megnathead)
        
    }
    
    
    

    @IBAction func startTrack(_ sender: Any) {
        
        
        let alertController = UIAlertController.init(title: "Message", message: "Do you want to save your path?", preferredStyle: .alert)
        let action = UIAlertAction(title: "SAVE", style: .default, handler: { (alert) in
            
            self.locationManager.stopUpdatingLocation()
            self.self.createMarker(loc: (self.path?.track.last!)!, name: "_flag_ending")
            self.setMapBounds()
            self.createPath()
           
        })
        
        let actionCancel = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        alertController.addAction(action)
        alertController.addAction(actionCancel)
        self.present(alertController, animated: true, completion: nil)
       

        
        
      }
    func showDarkBackgroudOnMap() {
        let image = UIImage(named: "MapBackground")
        var overlayBounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2DMake(84.922810, -179.194066), coordinate: CLLocationCoordinate2DMake(-84.357106, 15.164965))
        mapBackgroundOverlayer1 = GMSGroundOverlay(bounds: overlayBounds, icon: image)
        mapBackgroundOverlayer1.bearing = 0
        mapBackgroundOverlayer1.map = self.mapShow
        
        overlayBounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2DMake(84.969265, -179.300975), coordinate: CLLocationCoordinate2DMake(-84.860203, -15.088306))
        mapBackgroundOverlayer2 = GMSGroundOverlay(bounds: overlayBounds, icon: image)
        mapBackgroundOverlayer2.bearing = 0
        mapBackgroundOverlayer2.map = self.mapShow
        
        overlayBounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2DMake(84.984656, -15.040008), coordinate: CLLocationCoordinate2DMake(-84.357106, 15.164965))
        mapBackgroundOverlayer3 = GMSGroundOverlay(bounds: overlayBounds, icon: image)
        mapBackgroundOverlayer3.bearing = 0
        mapBackgroundOverlayer3.map = self.mapShow
    }
    
    @IBAction func shareCo(_ sender: Any) {
        if let controller1 = self.storyboard?.instantiateViewController(withIdentifier: "share") as? SharedLocationViewController{
            let overlayTransitioningDelegate = OverlayTransitionDelegate()
            controller1.transitioningDelegate = overlayTransitioningDelegate
            controller1.modalPresentationStyle = .custom
            
            
           
            controller1.lat = showlat
            controller1.long = showLong
            
            self.navigationController?.present(controller1, animated: true, completion: nil)
        }
        //self.navigationController?.present(controller1, animated: true, completion: nil)
        
    }
    func clearMapViewBackground() {
        self.mapBackgroundOverlayer1.map = nil
        self.mapBackgroundOverlayer2.map = nil
        self.mapBackgroundOverlayer3.map = nil
        self.mapShow.mapType = .hybrid
    }
    
    
    @IBAction func addPhotot(_ sender: Any) {
       //createMarker(loc: currentCoor!, name: "edit_selected")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as! AddingPostViewController
        vc.getCoor = currentCoor
        vc.delegate = self
       
    }
    func passIt(de1: String, lc1: CLLocation, im1: UIImage, cat1: String) {
        let post1 = Post(de: de1, lc: lc1, im: im1, cat: cat1)
        postList.append(post1)
        createMarker(loc: lc1, name: "edit_selected")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        //print(postList)
        for i in postList{
            var c = i
            //print(c)
            if marker.position.latitude == c.lco!.coordinate.latitude && marker.position.longitude == c.lco!.coordinate.longitude {
                //print(c.category)
                //print(c.desc)
                let vc = storyboard?.instantiateViewController(withIdentifier: "showm") as! ShowMarkerViewController
                vc.getDesc = c.desc!
                vc.getMess = c.category!
                vc.getImg = c.img
                self.present(vc, animated: true, completion: nil)
                
                
            }
        }
        return true
    }
    
    
    
    
    
}
