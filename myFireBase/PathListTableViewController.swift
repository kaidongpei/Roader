//
//  PathListTableViewController.swift
//  myFireBase
//
//  Created by kaidong pei on 10/26/17.
//  Copyright © 2017 kaidong pei. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import CoreLocation
import SWMessages



class PathListTableViewController: UITableViewController ,UISearchBarDelegate{
   
    
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var barPP: UIBarButtonItem!
    @IBOutlet var tb: UITableView!
    var pathList: [Path] = []
    var filterPathList: [Path] = []
    var path: Path?
    var ref : DatabaseReference?
    var storageRef : StorageReference?
    typealias completionHandler = (Any) -> ()
    var bb = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PATH LIST"
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        getPathList()
        tb.tableFooterView = UIView()
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationItem.leftBarButtonItem = nil;
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton;
        setupNavigationWithColor(UIColor.black)
        tb.backgroundView = UIImageView(image: UIImage(named:  "123"))
        tb.tableFooterView = UIView()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.filterPathList.count
    }
    
    func setupNavigationWithColor(_ color: UIColor) {
        let font = UIFont.boldSystemFont(ofSize: 20);
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : color, NSAttributedStringKey.font : font as Any]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = color
        
    }
    func getPathList(){
        if let user = Auth.auth().currentUser{
            ref?.child("Paths").observeSingleEvent(of: .value, with: { (snapShot) in
                for pathTable in snapShot.children {
                    
                    var pathInfo: Path
                    pathInfo = Path.init(withsnap: pathTable as! DataSnapshot)
                    if pathInfo.userID == user.uid{
                        self.pathList.append(pathInfo)
                       
                        
                    }
                }
                self.filterPathList = self.pathList
                self.tb.reloadData()
            })
        }
    }
    func getAllPathList(){
        ref?.child("Paths").observeSingleEvent(of: .value, with: { (snapShot) in
            for pathTable in snapShot.children {
                
                var pathInfo: Path
                pathInfo = Path.init(withsnap: pathTable as! DataSnapshot)
                if pathInfo.publicOrPrivate == "Public" {
                    self.pathList.append(pathInfo)
                }
            }
            self.filterPathList = self.pathList
            self.tb.reloadData()
            
            
        })
        
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PathListTableViewCell
        cell.userName.text = self.filterPathList[indexPath.row].pname
        cell.pathDate.text = "Distance: " + self.filterPathList[indexPath.row].distance!
        cell.time.text = "Date create: " + self.filterPathList[indexPath.row].date!
        cell.followerCount.text = String(self.filterPathList[indexPath.row].follower.count)
        
        cell.theButton.tag = indexPath.row
        cell.theButton.addTarget(self, action: #selector(mapsHit), for: UIControlEvents.touchUpInside)
        
        
      
        let vv = self.filterPathList[indexPath.row].pathMode
        cell.modeImage.image = UIImage(named: vv!)
        return cell
    }
    
    @objc func mapsHit(sender: UIButton){
        let indexPathOfThisCell = sender.tag
       // print("This button is at \(indexPathOfThisCell) row")
        bb = self.filterPathList[indexPathOfThisCell].follower
        // get indexPath.row from cell
        // do something with it
         let controller = self.storyboard?.instantiateViewController(withIdentifier: "follower") as? FollowerViewController
        controller?.NewPathList = filterPathList
        controller?.bb = bb
                
        
        self.navigationController?.pushViewController(controller!, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(self.filterPathList[indexPath.row].pathID!)
        getUserPathTrack(PathId: self.filterPathList[indexPath.row].pathID!) { (drawtrack) in


            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "showpath") as? ShowPathViewController{
                if  let lineForPath = drawtrack as? [CLLocation] {
                    getID = self.filterPathList[indexPath.row].pathID!
                    
                    self.path = Path()
                    self.path?.track = lineForPath
                    controller.path = self.path
                    controller.getId = getID
                   
                }
                self.navigationController?.present(controller, animated: true)
           }
        }
    }

    
    
    func getUserPathTrack (PathId: String, completion:@escaping completionHandler) {
        var tracklat: CLLocationDegrees?
        var tracklong: CLLocationDegrees?
        var userTrack: [CLLocation] = []
        //let trackName = "UserTrack/"+"\(String(describing: PathId)).txt"
        let jsonName = "UserTrack/"+"\(String(describing: PathId)).json"
        //let jsonName = "UserTrack/"+"-KxfB3ITuykqAQ7OEVnb.json"
        
        storageRef?.child(jsonName).getData(maxSize: Int64(Int.max)) { (data, error) in
            if error == nil{
                do{
                    
                    if let trackJson = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, Any>{
                        if let trackInfo = trackJson["tracks"] as? [[String: Any]] {
                            
                          
                            
                            
                            for item in trackInfo {
                                tracklat = item["lat"] as? CLLocationDegrees
                                tracklong = item["long"] as? CLLocationDegrees
                                let trackcor = CLLocation(latitude: tracklat!, longitude: tracklong!)
                                userTrack.append(trackcor)
                            }
                            completion(userTrack)
                        }
                    }
                }catch let error as NSError {
                    print(error.description)
                }
                
            }else{
                
            }
          
        }
       
    }

    @IBAction func publicorprivate(_ sender: Any) {
        if barPP.title == "ALL PATH" {
            pathList = []
            barPP.title = "MY PATH"
            getAllPathList()
            
        } else if barPP.title == "MY PATH"{
            pathList = []
            barPP.title = "ALL PATH"
            getPathList()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text == nil || (searchBar.text == "") {
            SWMessage.sharedInstance.showNotificationWithTitle("Search bar cannot be empty", subtitle: "Alert", type: .error)
        }else{
            filterTableViewForEnterText(searchText: searchBar.text!)
            
        }
        search.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filterPathList = pathList
        self.tb.reloadData()
    }
    func filterTableViewForEnterText(searchText: String) {
        filterPathList = pathList.filter({($0.pname?.contains(searchText))!})
        self.tb.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
    }
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        return true
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        if let controller = segue.destination as? FollowerViewController{
//            controller.NewPathList = filterPathList
//            controller.bb = bb
//        }}
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

}
