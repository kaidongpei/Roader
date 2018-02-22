//
//  Post.swift
//  myFireBase
//
//  Created by kaidong pei on 11/16/17.
//  Copyright © 2017 kaidong pei. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit


class Post {
    var desc: String?
    var lco: CLLocation?
    var img: UIImage?
    var category: String?
    
    init(de: String, lc: CLLocation, im: UIImage, cat: String){
        desc = de
        lco = lc
        img = im
        category = cat
    }
}
