//
//  ShowMarkerViewController.swift
//  myFireBase
//
//  Created by kaidong pei on 11/16/17.
//  Copyright © 2017 kaidong pei. All rights reserved.
//

import UIKit
import CoreLocation

class ShowMarkerViewController: UIViewController {

    @IBOutlet weak var message: UILabel!
    
    @IBOutlet weak var showImg: UIImageView!
    
    @IBOutlet weak var desc: UITextView!
    
    var getList:[Post] = []
    
    var getMess: String?
    var getDesc: String?
    var getImg: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        message.text = getMess
        desc.text = getDesc
        showImg.image = getImg
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
