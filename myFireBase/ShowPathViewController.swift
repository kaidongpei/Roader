//
//  ShowPathViewController.swift
//  myFireBase
//
//  Created by kaidong pei on 10/27/17.
//  Copyright © 2017 kaidong pei. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ShowPathViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate{

    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    var trackinfo: [String:Double] = [:]
    var trackdata: [[String:Double]] = []
    var trackJson: [String:[[String:Double]]] = [:]
    var storageRef : StorageReference?
    var polyline = GMSPolyline()
    var gmsPath = GMSMutablePath()
    var animatedMaker = GMSMarker()
    var path: Path?
    var tr: [CLLocation]?
    var databaseRef: DatabaseReference?
    var getId: String?
    var allPost: [getPost] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        locationManager.delegate = self
        mapView.delegate = self
        
        mapView.mapType = .satellite
        getPostFunc()
        
        
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
   
//    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
//
//        for i in allPost{
//            let c = i
//            print(c)
//            if marker.position.latitude == c.lco?.latitude && marker.position.longitude == c.lco?.longitude {
//            print("coming")
//            let vc = storyboard?.instantiateViewController(withIdentifier: "showm") as! ShowMarkerViewController
//                vc.getDesc = c.desc!
//                vc.getMess = c.category!
//                let url = URL(string: c.img!)
//                let data = try? Data(contentsOf: url!)
//                vc.getImg = UIImage(data: data!)
//                self.present(vc, animated: true, completion: nil)
//
//
//
//           }
//        }
//        return true
//    }
    
    
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
    
    func createMarker(loc: CLLocation, name: String) {
        
        let maker = GMSMarker()
        maker.position = loc.coordinate
        maker.title = "Hello"
        maker.icon = UIImage(named:name)
        maker.isDraggable = true
        maker.map = mapView
        mapView.camera = GMSCameraPosition(target: loc.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        
        
        
    }
    
    func setMapBounds() {
        let bounds = GMSCoordinateBounds(path: gmsPath)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 80.0)
        mapView.moveCamera(update)
        mapView.setMinZoom(self.mapView.minZoom, maxZoom: self.mapView.maxZoom)
    }
    
    func addRouteToPath(loc: CLLocation) {
        gmsPath.add(loc.coordinate)
        polyline.path = gmsPath
        self.polyline.strokeColor = UIColor(red: 0.0/255.0, green: 255.0/255, blue:230.0/255, alpha: 1.0)
        polyline.strokeWidth = 5
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)
        polyline.map = mapView
        CATransaction.commit()
    }
    
    
    @IBAction func done(_ sender: Any) {
        //self.dismiss(animated: true, completion: nil)
//        let controller = storyboard?.instantiateViewController(withIdentifier: "following") as! FollowingPathViewController
//        controller.getPath = path
//        navigationController?.pushViewController(controller, animated: true)
    }
    

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        let controller = segue.destination as! FollowingPathViewController
//            controller.getPath = path}
//    }
//  
//    
//}
//
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? FollowingPathViewController{
            controller.path = path
            controller.getId = getId

        }
  }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
 
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
