//
//  TagCell.swift
//  FamilyFirst
//
//  Created by Lifeboat on 14/01/26.
//

import UIKit

class TagCell: UICollectionViewCell {

    @IBOutlet weak var lblText: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    func setupUI() {
        contentView.backgroundColor = UIColor(hex: "#F5F5F5")
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        // Add border for better visibility
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.clear.cgColor
        
        // Default text color
        lblText.textColor = .darkGray
    }
    
    func setSelected(_ selected: Bool) {
        let greenColor = UIColor(red: 7/255, green: 104/255, blue: 57/255, alpha: 1) // #076839
        
        if selected {
            // Selected state - Only text green
            lblText.textColor = greenColor
        } else {
            // Normal state
            lblText.textColor = .darkGray
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setSelected(false)
        lblText.text = nil
    }
}
