//
//  AddMemberCell.swift
//  FamilyFirst
//
//  Created by Lifeboat on 09/01/26.
//

import UIKit

class AddMemberCell: UITableViewCell {

    @IBOutlet weak var addBtn: UIButton!
    
    var onAddTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
           }

    @IBAction func addBtnTapped(_ sender: UIButton) {
        onAddTapped?()  // ← Trigger closure
    }
}
