//
//  AddingPostViewController.swift
//  myFireBase
//
//  Created by kaidong pei on 11/15/17.
//  Copyright © 2017 kaidong pei. All rights reserved.
//

import UIKit
import TwicketSegmentedControl
import CoreLocation

protocol passPost {
    func passIt(de1: String, lc1: CLLocation, im1: UIImage, cat1: String)
}

class AddingPostViewController: UIViewController, UITextViewDelegate, TwicketSegmentedControlDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var text: UITextView!
    
    var messageType = "Warning"
    var getCoor : CLLocation?
   
    var delegate: passPost?
    //var getString : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(getCoor)
       
        
        
        let titles = ["Warning", "Recommendation", "Exploration" ]
        let frame = CGRect(x: 0, y: 250, width: view.frame.width, height: 40)
        
        let segmentedControl = TwicketSegmentedControl(frame: frame)
        segmentedControl.setSegmentItems(titles)
        segmentedControl.delegate = self
        view.addSubview(segmentedControl)
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didSelect(_ segmentIndex: Int){
        if segmentIndex == 0{
            messageType = "Warning"
        } else if segmentIndex == 1 {
            self.messageType = "Recommendation"
        } else{
            self.messageType = "Exploration"
        }
        
    }
    
    @IBAction func imgPick(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(image, animated: true)
        
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = UIColor.black
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            img.image = image
        }
        else
        {
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    @IBAction func save(_ sender: Any) {
//        post.category = messageType
//        post.desc = text.text
//        post.img = img.image
//        post.lco = getCoor
        
        delegate?.passIt(de1: text.text, lc1: getCoor!, im1: img.image!, cat1: messageType)
        navigationController?.popViewController(animated: true)
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let vc = segue.destination as? MapViewController
//        vc?.post1 = post
//    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
