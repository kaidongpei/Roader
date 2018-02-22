//
//  LogOnTableViewController.swift
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

class LogOnTableViewController: UITableViewController {

    @IBOutlet weak var userEmail: UITextField!
    
    @IBOutlet weak var userPass: UITextField!
    
    @IBOutlet weak var userRePass: UITextField!
    
    @IBOutlet weak var userFname: UITextField!
    
    @IBOutlet weak var userLname: UITextField!
    
    @IBOutlet weak var userPhone: UITextField!
    
    @IBOutlet weak var userBank: UITextField!
    @IBOutlet var tb: UITableView!
    var ref: DatabaseReference?
    var storageRef = StorageReference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        title = "SIGNUP"
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationItem.leftBarButtonItem = nil;
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton;
        setupNavigationWithColor(UIColor.black)
        tb.backgroundView = UIImageView(image: UIImage(named:  "123"))
        

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
            return 3
        } else if section == 1{
            return 4
        } else {
            return 1
        }
    }

    @IBAction func signUp(_ sender: Any) {
        if userFname.text?.count == 0 {
        
           SWMessage.sharedInstance.showNotificationWithTitle("Textfield cannot be empty", subtitle: "Alert", type: .error)
        }
        else if userLname.text?.count == 0 {
            SWMessage.sharedInstance.showNotificationWithTitle("Textfield cannot be empty", subtitle: "Alert", type: .error)
        }
        else if userEmail.text?.count == 0 {
            SWMessage.sharedInstance.showNotificationWithTitle("Textfield cannot be empty", subtitle: "Alert", type: .error)
        }
        else if userPhone.text?.count == 0 {
            SWMessage.sharedInstance.showNotificationWithTitle("Textfield cannot be empty", subtitle: "Alert", type: .error)
        }
        else if userPass.text?.count == 0 {
            SWMessage.sharedInstance.showNotificationWithTitle("Textfield cannot be empty", subtitle: "Alert", type: .error)
        }else  if userBank.text?.count == 0 {
            SWMessage.sharedInstance.showNotificationWithTitle("Textfield cannot be empty", subtitle: "Alert", type: .error)
        } else if userPass.text != userRePass.text {
          SWMessage.sharedInstance.showNotificationWithTitle("Password does not match", subtitle: "Alert", type: .error)
        }else {
            Auth.auth().createUser(withEmail: userEmail.text!, password: userPass.text!) { (user, error) in
                if error == nil {
                    //
                    let drive_list: [String] = [""]
                    let userDict = ["FirstName": self.userFname.text as! String,
                                    "LastName":self.userLname.text!,
                                    "Password": self.userPass.text!,
                                    "UserId": user?.uid,
                                    "EmailID": self.userEmail.text!,
                                    "PhoneNum": self.userPhone.text!,
                                    "BankBalance": "$" + self.userBank.text!] as [String : Any]
                    if let id = user?.uid {
                        self.ref?.child("Users").child(id).updateChildValues(userDict, withCompletionBlock: { (error, dataBaseRef) in
                            if error == nil {
                                Auth.auth().signIn(withEmail: self.userEmail.text!, password: self.userPass.text!) { (user, error) in
                                    if let err = error {
                                        print(err.localizedDescription)
                                        
                                    } else {
                                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "tab") as? TabBarViewController
                                        self.present(controller!, animated: true, completion: nil)
                                    }
                                }
                            }
                            else {
                                print(error?.localizedDescription)
                            }
                        })
                    }
                    self.dismiss(animated: true, completion: nil)
                }else{
                    print(error?.localizedDescription)
                }
            }
        }
    }
    
    
    
    func setupNavigationWithColor(_ color: UIColor) {
        let font = UIFont.boldSystemFont(ofSize: 20);
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : color, NSAttributedStringKey.font : font as Any]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = color
        
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
