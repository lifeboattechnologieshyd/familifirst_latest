//
//  DetailsCell.swift
//  FamilyFirst
//
//  Created by Lifeboat on 10/01/26.
//

import UIKit

class DetailsCell: UITableViewCell {

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var dateofbirthLbl: UILabel!
    @IBOutlet weak var phoneBgVw: UIView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var phonenoCopy: UIButton!
    @IBOutlet weak var mailBgVw: UIView!
    @IBOutlet weak var dateofbirthEdit: UIButton!
    @IBOutlet weak var mailLbl: UILabel!
    @IBOutlet weak var whatsappBtn: UIButton!
    @IBOutlet weak var phonenumberLbl: UILabel!
    @IBOutlet weak var mailBtn: UIButton!
    @IBOutlet weak var mailCopy: UIButton!
    @IBOutlet weak var relationLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        phoneBgVw.addCardShadow()
        mailBgVw.addCardShadow()
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
