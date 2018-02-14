//
//  CaretakerTableViewCell.swift
//  SilverBell
//
//  Created by Jackson Rossborough on 1/31/18.
//  Copyright © 2018 Jackson Rossborough. All rights reserved.
//

import UIKit

class CaretakerTableViewCell: UITableViewCell {
    
    //MARK: Properties
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
