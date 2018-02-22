//
//  pathModeViewController.swift
//  myFireBase
//
//  Created by kaidong pei on 10/26/17.
//  Copyright © 2017 kaidong pei. All rights reserved.
//

import UIKit
import SWMessages

protocol passInfo {
    func passStr(mode: String, pOrP: String, pathN: String)
}

class PathModeViewController: UIViewController {
    
    @IBOutlet weak var pathName: UITextField!
    var pathMode: String?
    var publicOrPrivare: String?
    var path: Path?
    var delegate: passInfo?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pathMode(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.tag == 1{
            pathMode = "EasyPathModeIconSec"
        } else if sender.tag == 2{
            pathMode = "MediumPathModeIconSec"
        } else {
            pathMode = "HardPathmodeIconSec"
        }
        //Path.Diffculty(rawValue: pathMode!)
    }
    
    @IBAction func publicOrPrivate(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.tag == 1{
            
            publicOrPrivare = "Public"
        } else {
            publicOrPrivare = "Private"
        }
        //path?.publicOrPrivate = publicOrPrivare
        
    }
    
    
    @IBAction func doneEdit(_ sender: Any) {
        
        if pathName.text?.count == 0{
            SWMessage.sharedInstance.showNotificationWithTitle("Textfield cannot be empty", subtitle: "Alert", type: .error)
        } else{
        
        if pathMode?.count == 0 || publicOrPrivare?.count == 0 {
            SWMessage.sharedInstance.showNotificationWithTitle("Please choose path mode", subtitle: "Alert", type: .error)
            
        } else if pathMode?.count != 0 && publicOrPrivare?.count != 0{
            delegate?.passStr(mode: pathMode!, pOrP: publicOrPrivare!, pathN: pathName.text!)
            }}
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
