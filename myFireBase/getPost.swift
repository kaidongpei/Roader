//
//  getPost.swift
//  myFireBase
//
//  Created by kaidong pei on 11/20/17.
//  Copyright © 2017 kaidong pei. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit


class getPost {
    var desc: String?
    var lco: CLLocationCoordinate2D?
    var img: String?
    var category: String?
    var ID: String?
    
    init(de: String, lc: CLLocationCoordinate2D, im: String, cat: String, id: String){
        desc = de
        lco = lc
        img = im
        category = cat
        ID = id
    }
}
