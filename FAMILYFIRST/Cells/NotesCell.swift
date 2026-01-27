//
//  NotesCell.swift
//  FamilyFirst
//
//  Created by Lifeboat on 10/01/26.
//

import UIKit

class NotesCell: UITableViewCell {

    @IBOutlet weak var bgVw: UIView!
    @IBOutlet weak var noteseditBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var notesLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgVw.addCardShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
