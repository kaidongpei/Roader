//
//  SharedLocationViewController.swift
//  myFireBase
//
//  Created by kaidong pei on 10/29/17.
//  Copyright © 2017 kaidong pei. All rights reserved.
//

import UIKit
import MessageUI

class SharedLocationViewController: UIViewController,MFMessageComposeViewControllerDelegate {
    
    
  
    
    @IBOutlet weak var currentCo: UILabel!
    var lat:String?
    var long: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentCo.text = lat! + "" + long!
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController!, didFinishWith result: MessageComposeResult) {
       
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func whatapp(_ sender: Any) {
        
        
    }
    
    @IBAction func msm(_ sender: Any) {
     if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Come to join me at " + currentCo.text!
            controller.recipients = ["12345678"]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
       }
    }
    
    @IBAction func copyit(_ sender: Any) {
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = "Come to join me at " + currentCo.text!
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
