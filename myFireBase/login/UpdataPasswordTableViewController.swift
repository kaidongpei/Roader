//
//  UpdataPasswordTableViewController.swift
//  myFireBase
//
//  Created by kaidong pei on 10/25/17.
//  Copyright © 2017 kaidong pei. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SWMessages

class UpdataPasswordTableViewController: UITableViewController {

    @IBOutlet var tb: UITableView!
    @IBOutlet weak var oldPass: UITextField!
    @IBOutlet weak var newPass: UITextField!
    @IBOutlet weak var reNewPass: UITextField!
    var ref :  DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tb.backgroundView = UIImageView(image: UIImage(named:  "123"))
        ref = Database.database().reference()

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
        if section == 0{
            return 1
        } else if section == 1{
            return 2
        } else {
            return 1
        }
    }
    
    
    @IBAction func submit(_ sender: Any) {
        
//        let user1 = Auth.auth().currentUser
//        let credential = FIREmailPasswordAuthProviderID.credentialWithEmail(email, password: currentPassword)
//
//        User?.reauthenticateWithCredential(credential, completion: { (error) in
//            if error != nil{
//                self.displayAlertMessage("Error reauthenticating user")
//            }else{
    
        
        if newPass.text == reNewPass.text{
            let newpass = newPass.text
            if let user = Auth.auth().currentUser {
                if let useid:Any = user.uid{
                    
                    user.updatePassword(to: newpass!, completion: { (error) in
                        SWMessage.sharedInstance.showNotificationWithTitle("Password Updataed", subtitle: "UPDATAED", type: .success)
                    })
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
        } else if newPass.text != reNewPass.text {
            SWMessage.sharedInstance.showNotificationWithTitle("Password not match", subtitle: "Alert", type: .error)
        }
        
//            }
//        })

        
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
