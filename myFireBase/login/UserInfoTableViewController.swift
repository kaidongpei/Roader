//
//  UserInfoTableViewController.swift
//  myFireBase
//
//  Created by kaidong pei on 10/25/17.
//  Copyright © 2017 kaidong pei. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SWMessages

class UserInfoTableViewController: UITableViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextViewDelegate {
    
    @IBOutlet var fb: UITableView!
    var ref :  DatabaseReference?
    var storageRef = StorageReference()

    @IBOutlet weak var userIMage: UIImageView!
    @IBOutlet weak var userFN: UITextField!
    @IBOutlet weak var userLN: UITextField!
    @IBOutlet weak var userPN: UITextField!
    @IBOutlet weak var userBB: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        fb.backgroundView = UIImageView(image: UIImage(named:  "123"))
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        let userID = Auth.auth().currentUser?.uid
        ref?.child("Users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.userFN.text = value?["FirstName"] as? String ?? ""
            self.userLN.text = value?["LastName"] as? String ?? ""
            self.userPN.text = value?["PhoneNum"] as? String ?? ""
            self.userBB.text = value?["BankBalance"] as? String ?? ""
           
            self.getImage(uid: userID!)
        }) { (error) in
            print(error.localizedDescription)
        }

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
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 1
        } else if section == 1{
            return 4
        } else {
            return 1
        }
    }
    
    
    @IBAction func imagePick(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(image, animated: true)
    }
    
    
    @IBAction func submit(_ sender: Any) {
        if let user = Auth.auth().currentUser {
            if let useid:Any = user.uid{
               
                let userDict = ["FirstName": userFN.text,
                                "LastName" : userLN.text,
                                "PhoneNumber": userPN.text,
                                "BankBlance": userBB.text]
                ref?.child("Users").child(user.uid).updateChildValues(userDict, withCompletionBlock: { (error, dataBaseRef) in
                    print(error?.localizedDescription)
                })
                uploadImage()
                SWMessage.sharedInstance.showNotificationWithTitle("User Inforamtion Updataed", subtitle: "UPDATAED", type: .success)
            }
            //self.dismiss(animated: true, completion: nil)
            SWMessage.sharedInstance.showNotificationWithTitle("User Inforamtion Updataed", subtitle: "UPDATAED", type: .success)
        }
    }
    
    func uploadImage(){
        SWMessage.sharedInstance.showNotificationWithTitle("User Inforamtion Updataed", subtitle: "UPDATAED", type: .success)
        if let user = Auth.auth().currentUser {
            guard let img = userIMage.image else { return  }
            let data = UIImageJPEGRepresentation(img, 0.8)
            let imgReference = storageRef.child("UserImages/\(String(describing: user.uid)).jpg")
            
            _ = imgReference.putData(data!, metadata: nil) { (metadata, error) in
                if error == nil{
                     SWMessage.sharedInstance.showNotificationWithTitle("User Inforamtion Updataed", subtitle: "UPDATAED", type: .success)
                }else{
                    print(error?.localizedDescription)
                    
                    
                }
                
            }
        }
        
    }
    
    func getImage(uid:String) {
       let islandRef = storageRef.child("UserImages/\(String(describing: uid)).jpg")
       // let imagename = "UserImages/\(String(describing: uid)).jpg"
            //let imagename = "UserImages/NEccZMNR4gUiHWXgrhObRXUqNng2.jpg"
            
       
            islandRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if error == nil{
                self.userIMage.image = UIImage(data: data!)
            }else{
                print(error?.localizedDescription)
                self.userIMage.image = UIImage(named: "people-1")
                
            }
            
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            userIMage.image = image
        }
        else
        {
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
