//
//  UserCell.swift
//  FamilyFirst
//
//  Created by Lifeboat on 09/01/26.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var copyLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var sahreBtn: UIButton!
    @IBOutlet weak var referalVw: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var bgVw: UIView!
    @IBOutlet weak var referalcodeLbl: UILabel!
    @IBOutlet weak var pictureEdit: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        bgVw.addCardShadow()
        referalVw.addDottedBorder(color: .systemGray5)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
