//
//  CreateEventCell.swift
//  FamilyFirst
//
//  Created by Lifeboat on 10/01/26.
//

import UIKit

class CreateEventCell: UITableViewCell {

    @IBOutlet weak var createEventbtn: UIButton!
    
    // 👈 Callback for button tap
    var onCreateEventTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        createEventbtn.addTarget(self, action: #selector(createEventBtnTapped), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onCreateEventTapped = nil
    }
    
    // 👈 Button action
    @objc private func createEventBtnTapped() {
        onCreateEventTapped?()
    }
}
