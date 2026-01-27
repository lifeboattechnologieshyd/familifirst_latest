//
//  MonthCell.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 19/01/26.
//

import UIKit

class MonthCell: UITableViewCell {

    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var eventLbl: UILabel!
    @IBOutlet weak var mainVw: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
