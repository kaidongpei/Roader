//
//  FollowerViewController.swift
//  myFireBase
//
//  Created by kaidong pei on 10/31/17.
//  Copyright © 2017 kaidong pei. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import CoreLocation
import SWMessages

class FollowerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var path:Path?
    var NewPathList: [Path] = []
    var userIDList = [String]()
    var userList:[User] = []
    var followerList:[User] = []
    var num = 0
    var ref :  DatabaseReference?
    var storageRef = StorageReference()
    var fname: String?
    var lname: String?
    var phone: String?
    var banl: String?
    var bb = [String]()
    var showFollower = true

    @IBOutlet weak var tb: UITableView!
    override func viewDidLoad() {
        title = "Follower"
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationItem.leftBarButtonItem = nil;
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton;
        setupNavigationWithColor(UIColor.black)
        tb.backgroundView = UIImageView(image: UIImage(named:  "123"))
        tb.tableFooterView = UIView()
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        
        
        
        
        getUser()
       
       print(userList)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    func setupNavigationWithColor(_ color: UIColor) {
        let font = UIFont.boldSystemFont(ofSize: 20);
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : color, NSAttributedStringKey.font : font as Any]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = color
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var list:[User] = []
        if showFollower == true{
            list = followerList}
        else if showFollower == false {
            list = userList
        }
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FollowerTableViewCell
        var list:[User] = []
        if showFollower == true{
            list = followerList
            
        }
        else if showFollower == false  {
            list = userList
        }
        cell.fname.text = list[indexPath.row].firstname! + "  " + list[indexPath.row].lastname!
        cell.email.text = list[indexPath.row].email
        cell.bankB.text = list[indexPath.row].bankBalance
        let id = list[indexPath.row].userID
        let islandRef = storageRef.child("UserImages/\(id!).jpg")
        
        islandRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if error == nil{
               cell.userImag.image = UIImage(data: data!)
            }else{
                print(error?.localizedDescription)
                cell.userImag.image = UIImage(named: "people-1")
                
            }
            
        }
        
        return cell
    }
    
    @IBAction func switchUser(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
             getFollower()
             showFollower = true
           
        }
          
            
         else if sender.selectedSegmentIndex == 1 {
            showFollower = false
            
        }
        
        self.tb.reloadData()
    }
    
    
    func getUser(){
       
            ref?.child("Users").observeSingleEvent(of: .value, with: { (snapShot) in
                for pathTable in snapShot.children {
                    //print(pathTable)
                    var userDe: User
                 
                    userDe = User.init(withsnap: pathTable as! DataSnapshot)
                    print(userDe)
//                    if userDe.userID == user.uid{
                        self.userList.append(userDe)
                    //print(self.userList)
//
//                    }
                }
                self.getFollower()
                self.tb.reloadData()
            })
        
    }
    
    
    func getFollower(){
        followerList = [User]()
        var i: User
        for i in userList{
            for v in bb{
                if i.userID == v {
                    followerList.append(i)
                    
                }
            }
            
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
