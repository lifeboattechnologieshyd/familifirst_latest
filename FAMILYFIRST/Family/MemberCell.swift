//
//  MemberCell.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 19/01/26.
//

import UIKit

class MemberCell: UITableViewCell {

    @IBOutlet weak var imgVw: UIView!
    @IBOutlet weak var relationLbl: UILabel!
    @IBOutlet weak var nameLbl: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
