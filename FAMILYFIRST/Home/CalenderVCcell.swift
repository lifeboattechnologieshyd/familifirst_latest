//
//  CalenderVCcell.swift
//  FamilyFirst
//
//  Created by Lifeboat on 13/01/26.
//

import UIKit

class CalenderVCcell: UITableViewCell {
    
    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var bgVw: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var dayLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
