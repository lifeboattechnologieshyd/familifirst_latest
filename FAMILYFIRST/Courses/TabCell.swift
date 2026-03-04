//
//  TabCell.swift
//  FamilyFirst
//
//  Created by Lifeboat on 14/01/26.
//

import UIKit

class TabCell: UICollectionViewCell {
    
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var img: UIImageView!
    
    // ✅ Primary Color - #076839
    let primaryColor = UIColor(red: 7/255, green: 104/255, blue: 57/255, alpha: 1.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // ✅ Set primary color background
        backgroundColor = primaryColor
        contentView.backgroundColor = primaryColor
        
        // Remove any layer background
        layer.backgroundColor = UIColor.clear.cgColor
        contentView.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColor = primaryColor
        contentView.backgroundColor = primaryColor
    }
    
    func loadCell(option: [String: Any]) {
        lblTitle.text = option["name"] as? String
        
        if let imageName = option["image"] as? String, !imageName.isEmpty {
            img.image = UIImage(named: imageName)
            img.isHidden = false
        } else {
            img.image = nil
            img.isHidden = true
        }
    }
}
