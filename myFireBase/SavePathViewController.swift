//
//  SavePathViewController.swift
//  myFireBase
//
//  Created by kaidong pei on 10/25/17.
//  Copyright © 2017 kaidong pei. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SavePathViewController: UIViewController , passInfo{
   
    

    @IBOutlet weak var mapView: GMSMapView!
    var trackinfo: [String:Double] = [:]
    var trackdata: [[String:Double]] = []
    var trackJson: [String:[[String:Double]]] = [:]
    var polyline = GMSPolyline()
    var gmsPath = GMSMutablePath()
    var animatedMarker = GMSMarker()
    var storageRef : StorageReference?
    var path: Path?
    var databaseRef: DatabaseReference?
     var databaseRefPost: DatabaseReference?
    var getKm: String?
    var getTime: String?
    var getMode: String?
    var getPOrP: String?
    var getPN: String?
    var getPostList:[Post] = []
    let userId = Auth.auth().currentUser?.uid ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationItem.leftBarButtonItem = nil;
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton;
        setupNavigationWithColor(UIColor.black)
        databaseRef =  Database.database().reference().child("Paths").childByAutoId()
        
        storageRef = Storage.storage().reference()
        
       // print(getPostList)

        // Do any additional setup after loading the view.
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
    override func viewWillAppear(_ animated: Bool) {
        if let track = path?.track{
            //print(track)
            for loc in track{
                addRouteToPath(loc: loc)
            }
            
            createMarker(loc: track.first!, name: "starting_point")
            createMarker(loc: track.last!, name: "_flag_ending")
            
        }
        setMapBounds()
    }
    
   
    
    
    @IBAction func donePath(_ sender: Any) {
        //databaseRef?.child("Paths").child(path?.pathID ?? "").updateChildValues(["pathName": path?.pathName ?? ""])
        createPath()
        navigationController?.popToRootViewController(animated: true)
       // ManagePath.uploadToFireBase(pathId: (path?.pathID!)!)
        //createPath()
       // saveToJsonFile()
    }
    
   
    func createMarker(loc: CLLocation, name: String)  {
        
        let marker = GMSMarker()
        marker.position = loc.coordinate
        marker.title = "MyMarker"
        marker.map = mapView
        marker.isDraggable = true
        marker.icon = UIImage(named: name)
    }
    
    func setMapBounds() {
        let bounds = GMSCoordinateBounds(path: self.gmsPath)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 80.0)
        self.mapView?.moveCamera(update)
        self.mapView?.setMinZoom(self.mapView!.minZoom, maxZoom: self.mapView!.maxZoom)
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
    func createPath(){
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let result = formatter.string(from: date)
        let calendar = NSCalendar.current
       
 
        path?.pathID = databaseRef?.key
        let userId = Auth.auth().currentUser?.uid ?? ""
        
        let pathDict = ["Name" :  getPN,
                        "UserId":userId,
                        "Ditance": getKm!,
                        "Time": getTime!,
                        "Date": result,
                        "Mode": getMode,
                        "PuclicOrPrivate": getPOrP!,
                        "PathID": (path?.pathID)!] as [String:Any]
        databaseRef?.updateChildValues(pathDict, withCompletionBlock: { (error, ref) in
            Database.database().reference().child("Users").child(userId).child("Paths").updateChildValues([ref.key : "id"])
            
            
            
            for vc in self.getPostList{
            self.uploadPost(vc)
            }
            self.saveToJsonFile()
            if let saveMap = self.storyboard?.instantiateViewController(withIdentifier: "SavePathViewController")as? SavePathViewController{
                saveMap.path = self.path
                self.navigationController?.pushViewController(saveMap, animated: true)
                
            }
        })
        
    }
    func uploadPost(_ i : Post){
        
        databaseRefPost = Database.database().reference().child("Paths").child((databaseRef?.key)!).child("Posts").childByAutoId()
            //print(databaseRefPost!)
        
            let postID = self.databaseRefPost?.key
            //print(postID)
            if i != nil{
           
            var imgUrl: URL?
            
                guard let img = i.img else { return  }
                
                let data = UIImageJPEGRepresentation(img, 0.8)
                 let imgReference = self.storageRef?.child("Posts/\(String(describing: postID!)).jpg")
//
                 _  = imgReference?.putData(data!, metadata: nil) { (metadata, error) in
                if error != nil{

                    print(error)
                }else{
                   imgUrl = metadata?.downloadURL()
                    //print(imgUrl)
                
                    let postDict = ["Description" :  i.desc!,
                                    "Location": String(describing: i.lco!),
                                    "Category": i.category!,
                                    "UserID" : self.userId,
                                    "PostID": (postID)!,
                                    "ImageURL": String(describing: imgUrl!),
                                    "PathID" : (self.path?.pathID)!] as [String:Any]
                    Database.database().reference().child("Paths").child((self.path?.pathID!)!).child("Posts").child(postID!).updateChildValues(postDict, withCompletionBlock: { (error, ref) in
                        
                    })
                }
              }
            }else {
                    print("no post")
        }
     }
    
    func passStr(mode: String, pOrP: String, pathN: String ) {
        getMode = mode
        getPOrP = pOrP
        getPN = pathN
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let contro = segue.destination as! PathModeViewController
        contro.delegate = self
    }
    
    func saveToJsonFile() {
        // Get the url of Track.json in document directory
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileUrl = documentDirectoryUrl.appendingPathComponent("\(String(describing: (path?.pathID)!)).json")

        
        for item in (path?.track)! {
            trackinfo["long" ] =  item.coordinate.longitude
            trackinfo["speed" ] =  item.speed
            trackinfo["lat"] = item.coordinate.latitude
            trackinfo["altitude"] = item.altitude
            trackdata.append(trackinfo)
            trackinfo = [:]
        }
        trackJson["tracks"] = trackdata
        
        // Transform array into data and save it into file
        do {
            let data = try JSONSerialization.data(withJSONObject: trackJson, options: [])
            try data.write(to: fileUrl, options: [])
            
            let jsonName = "UserTrack/"+"\(String(describing: (path?.pathID)!)).json"
            storageRef = storageRef?.child(jsonName)
            let metaData = StorageMetadata()
            metaData.contentType = "json"
            storageRef?.putData(data, metadata: metaData) { (data, error) in
                if let firebaseError = error {
                    //                        TWMessageBarManager.sharedInstance().showMessage(withTitle: "Alert", description: firebaseError.localizedDescription, type: .error)
                    return
                }
                self.navigationController?.popViewController(animated: true)
                
            }
            
            //print(fileUrl)
        } catch {
            print(error)
        }
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
