//
//  Path.swift
//  myFireBase
//
//  Created by kaidong pei on 10/25/17.
//  Copyright © 2017 kaidong pei. All rights reserved.
//

import Foundation

import Foundation
import CoreLocation
import Firebase
import FirebaseAuth
import FirebaseDatabase

class Path:NSObject {
    var pathID:String?
    //var pathName:String?
    var track: Array<CLLocation> = []
    var date: String?
    var distance: String?
    var pathMode: String?
    var publicOrPrivate: String?
    var time: String?
    var userID : String?
    var pname: String?
    var follower = [String]()
  
    
    
    init(withsnap snapshot:DataSnapshot) {
        guard let dict = snapshot.value as? [String:Any] else { return }
        pathID = dict["PathID"] as? String
        date = dict["Date"] as? String
        distance = dict["Ditance"] as? String
        userID = dict["UserId"] as? String
        time = dict["Time"] as? String
        pname = dict["Name"] as? String
        pathMode = dict["Mode"] as! String
        guard let followers = (dict["Followers"]) else{
            return }
        for i in followers as! NSDictionary{
            let key = i.key
            follower.append(key as! String)}
       publicOrPrivate = dict["PuclicOrPrivate"] as? String
        
    }
    override required init() {
        super.init()
    }
    enum Diffculty:String{
        case Hard = "HardPathmodeIconSec"
        case Med = "MediumPathModeIconSec"
        case easy = "EasyPathModeIconSec"
    }
}

typealias completionhandler = (Any) -> ()

class ManagePath: NSObject {
    
    static var doc_url: URL?
    static var file_url: URL?
    static var flag = true
    static let fileManager = FileManager.default
    static var fileHandle: FileHandle?
    static var uuid: String?
    
    private override init() {}
    static var sharedinstance = ManagePath()
    
    static func addInitialPath(pathid: String){
        do {
            doc_url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            if let id = pathid as? String{
                file_url = doc_url?.appendingPathComponent("\(id).json")
                let initial = ("{\"path\":[" as NSString).data(using: String.Encoding.utf8.rawValue)
                if let url = file_url {
                    if fileManager.fileExists(atPath: (url.path)) {
                        fileHandle = FileHandle(forUpdatingAtPath: (url.path))
                    } else if fileManager.createFile(atPath: (url.path), contents: initial, attributes: nil) {
                        fileHandle = FileHandle(forWritingAtPath: (url.path))
                    }
                }
            }
        }
        catch let error as NSError{
            print(error.description)
        }
    }
    
    static func addEndpath(pathId: String) {
        
        guard let url = file_url else{
            return
        }
        let fileHandle = FileHandle(forWritingAtPath: (url.path))
        fileHandle?.seekToEndOfFile()
        fileHandle?.write("]}".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!)
        
        uploadToFireBase(pathId: pathId)
    }
    
    static func addCordinateTopath(latidude: Double, longitude: Double) {
        
        fileHandle?.seekToEndOfFile()
        if flag{
            let data = "{\"latitude\":\"\(latidude)\", \"longitude\":\"\(latidude)\"}"
            fileHandle?.write(data.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!)
            flag = false
        }
        else {
            let data = ",{\"latitude\":\"\(latidude)\", \"longitude\":\"\(longitude)\"}"
            fileHandle?.write(data.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!)
        }
    }
    
    static func getAllPathsList(completion: @escaping handler) {
        var pathList: [String] = []
        ManipulateUser.getPathList { (path_list) in
            if let list = path_list as? [String] {
                pathList = list
            }
            else {
                pathList = []
            }
            completion(pathList)
        }
    }
    
    static func uploadToFireBase(pathId:String) {
        var storageRef = StorageReference()
        let user = Auth.auth().currentUser
        guard let url = file_url else{
            return
        }
        do{
            guard let data: Data = try Data(contentsOf: url) else {
                return
            }
            let metaData = StorageMetadata()
            metaData.contentType = "text"
            let file_name = "UserTrack/"+"\(String(describing: pathId)).json"
            storageRef = storageRef.child(file_name)
            storageRef.putData(data,metadata: metaData) { (data, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                else {
                    print(error?.localizedDescription)
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    static func getPath(name: String, completion: @escaping handler){
        var storageRef = StorageReference()
        var path: [(String,String)] = []
        let file_name = "PathFiles/\(String(describing: name)).txt"
        storageRef = storageRef.child(file_name)
        storageRef.getData(maxSize: Int64(Int.max)) { (data, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                guard let path_data = data else {
                    return
                }
                do {
                    //print(path_data)
                    if let path_json = try JSONSerialization.jsonObject(with: path_data, options: []) as? Dictionary<String,Any> {
                        if let new_path = path_json["path"] as? [Dictionary<String,String>] {
                            for cord in new_path {
                                path.append((cord["latitude"]!, cord["longitude"]!))
                            }
                            completion(path)
                        }
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
}

