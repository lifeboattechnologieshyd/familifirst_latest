//
//  AddCell.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 05/02/26.
//

import UIKit

class AddCell: UITableViewCell {

    @IBOutlet weak var addBtn: UIButton!
    
    var onAddEventTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onAddEventTapped = nil
    }
    
    @IBAction func addBtnTapped(_ sender: UIButton) {
        onAddEventTapped?()
    }
}

