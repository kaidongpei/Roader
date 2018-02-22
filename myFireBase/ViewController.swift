//
//  ViewController.swift
//  myFireBase
//
//  Created by kaidong pei on 10/17/17.
//  Copyright © 2017 kaidong pei. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase


class ViewController: UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationItem.leftBarButtonItem = nil;
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton;
        setupNavigationWithColor(UIColor.white)
       
        // Do any additional setup after loading the view, typically from a nib.
    }
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setupNavigationWithColor(_ color: UIColor) {
        let font = UIFont.boldSystemFont(ofSize: 20);
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : color, NSAttributedStringKey.font : font as Any]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = color
        
    }

}

