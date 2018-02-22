//
//  User.swift
//  myFireBase
//
//  Created by kaidong pei on 10/26/17.
//  Copyright © 2017 kaidong pei. All rights reserved.
//

import Foundation

import Firebase
import FirebaseAuth
import FirebaseDatabase

class User {
    
    var firstname: String?
    var lastname: String?
    var email: String?
    var bankBalance: String?
    var userID: String?
    
    init(withsnap snapshot:DataSnapshot) {
        guard let dict = snapshot.value as? [String:Any] else { return }
        firstname = dict["FirstName"] as? String
        lastname = dict["LastName"] as? String
        email = dict["EmailID"] as? String
        bankBalance = dict["BankBalance"] as? String
        userID = dict["UserId"] as? String
        //city = dict["City"] as? String
        //email = dict["EmailID"] as? String
        //password = dict["Password"] as? String
        
    }
    
    
}

typealias handler = (Any) -> ()

class ManipulateUser: NSObject {
    private override init() {}
    static var sharedinstance = ManipulateUser()
    
    func getUser(completion: @escaping handler){
        //var user: User?
        let ref: DatabaseReference = Database.database().reference()
        let u = Auth.auth().currentUser
        
        ref.child("Users").child((u?.uid)!).observeSingleEvent(of: .value) { (snapshot) in
            let user = User(withsnap: snapshot)
            completion(user)
        }
    }
    
    static func add_drive_name(uuid: String) {
        
        let ref: DatabaseReference = Database.database().reference()
        
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        ref.child("Users").child(user.uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? Dictionary<String,Any> else {
                return
            }
            var new_drive_list: [String] = []
            
            if let drive_list = value["DrivePath"] as? [String] {
                new_drive_list = drive_list
                new_drive_list.append(uuid)
            }
            let new_dict = ["DrivePath": new_drive_list]
            ref.child("Users").child(user.uid).updateChildValues(new_dict, withCompletionBlock: { (error, dataBaseRef) in
                if error != nil {
                    print(error?.localizedDescription)
                }
            })
        }
    }
    
    static func getPathList(completion: @escaping handler) {
        var pathList: [String] = []
        let ref: DatabaseReference = Database.database().reference()
        let u = Auth.auth().currentUser
        
        ref.child("Users").child((u?.uid)!).child("Paths").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? Dictionary<String,Any> else {
                return
            }
            guard let list = value["Paths"] as? [String] else {
                return
            }
            pathList = list
            completion(pathList)
        }
    }
}
