//
//  AddFamilyMemberCell.swift
//  FamilyFirst
//
//  Created by Lifeboat on 09/01/26.
//

import UIKit

class AddFamilyMemberCell: UITableViewCell {

    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var mobilenumberTf: UITextField!
    @IBOutlet weak var notesTv: UITextView!
    @IBOutlet weak var dateofbirthTf: UITextField!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var relationTf: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        notesTv.addCardShadow()
        nameTf.addCardShadow()
        mobilenumberTf.addCardShadow()
        dateofbirthTf.addCardShadow()
        emailTf.addCardShadow()
        relationTf.addCardShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
