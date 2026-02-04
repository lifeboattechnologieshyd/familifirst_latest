//
//  MemberCell.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 27/01/26.
//

import UIKit

class MemberCell: UITableViewCell {

    @IBOutlet weak var imgVw: UIView!
    @IBOutlet weak var relationLbl: UILabel!
    @IBOutlet weak var checkmarkBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    
    var onCheckTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgVw.addCardShadow()
        
        checkmarkBtn.isUserInteractionEnabled = true
        
        checkmarkBtn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func btnAction() {
        onCheckTapped?()
    }
    
    func configure(with member: FamilyMember, isSelected: Bool) {
        nameLbl.text = member.fullName ?? "Unknown"
        relationLbl.text = member.relationType ?? ""
        
        checkmarkBtn.isUserInteractionEnabled = true
        
        if isSelected {
            if let customImage = UIImage(named: "checkbox") {
                checkmarkBtn.setImage(customImage, for: .normal)
                checkmarkBtn.tintColor = .clear 
            } else {
                checkmarkBtn.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
                checkmarkBtn.tintColor = .systemGreen
            }
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
            let image = UIImage(systemName: "circle", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
            checkmarkBtn.setImage(image, for: .normal)
            checkmarkBtn.tintColor = .gray
        }
    }
}
