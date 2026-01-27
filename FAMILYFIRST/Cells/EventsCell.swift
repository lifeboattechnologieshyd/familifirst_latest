//
//  EventsCell.swift
//  FamilyFirst
//
//  Created by Lifeboat on 10/01/26.
//

import UIKit

class EventsCell: UITableViewCell {

    @IBOutlet weak var bgVw: UIView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var eventnameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
