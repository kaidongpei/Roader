//
//  PathListTableViewCell.swift
//  myFireBase
//
//  Created by kaidong pei on 10/26/17.
//  Copyright © 2017 kaidong pei. All rights reserved.
//

import UIKit

class PathListTableViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var pathDate: UILabel!
    @IBOutlet weak var modeImage: UIImageView!
    @IBOutlet weak var followerCount: UILabel!
    
    @IBOutlet weak var theButton: UIButton!
    @IBOutlet weak var time: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func myButton(_ sender: UIButton) {
        
        
        
    }
    
    

}
