//
//  LocalInfoViewController.swift
//  myFireBase
//
//  Created by kaidong pei on 10/25/17.
//  Copyright © 2017 kaidong pei. All rights reserved.
//

import UIKit
import CoreLocation

class LocalInfoViewController: UIViewController, CLLocationManagerDelegate {
      var theUrl = "http://samples.openweathermap.org/data/2.5/weather?lat=35&lon=139&appid=ddbb425e0273a6624baba5b77e648bc4"

    @IBOutlet weak var trun: UIImageView!
    @IBOutlet weak var showImg: UIImageView!
    @IBOutlet weak var weatherShow: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        getinfo()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getinfo(){
        var city = ""
        URLSession.shared.dataTask(with: URL(string: theUrl)!) { (data, response, error) in
            if error == nil{
                
                do{
                    
                    if let jsonresult = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, Any>{
                        city = (jsonresult["name"] as? String)!
                        let info = jsonresult["weather"] as? NSArray
                        
                        
                        let v = info![0] as! NSDictionary
                        let desc = v["description"] as! String
                        let main1 = v["main"] as! String
                        
                        let vv = Weather.Condition(rawValue: desc)?.title
                        let imageName = String(describing: vv!)
                        DispatchQueue.main.async {
                            
                            //self.nameLabel.text = city
                            //self.mainLabel.text = desc
                            self.weatherShow.text = main1
                            self.showImg.image = UIImage(named: imageName)
                         }
                        
                    }
                    
                }
                catch{
                    print(error)
                }
            }
        }.resume()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy < 0 {
            return
        }
        let megnathead = CGFloat(FTMathCalculations.DegreesToRadians(newHeading.magneticHeading))
        //print(CGAffineTransform(rotationAngle: -megnathead))
        trun.transform = CGAffineTransform(rotationAngle: -megnathead)
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
