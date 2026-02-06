//
//  MonthCell.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 19/01/26.
//

import UIKit

class MonthCell: UITableViewCell {

    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var leftVw: UIView!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var eventLbl: UILabel!
    @IBOutlet weak var mainVw: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mainVw.layer.cornerRadius = 8
        mainVw.clipsToBounds = true
    }
    
    func configure(with event: Event) {
        dateLbl.text = event.dateFormatted
        dayLbl.text = event.daysToGo
        eventLbl.text = event.eventName
        
        if let colorHex = event.colourCode, !colorHex.isEmpty {
            let color = UIColor(hexString: colorHex) ?? UIColor(hexString: "#076839") ?? .systemGreen
            
            leftVw.backgroundColor = color
            
            mainVw.layer.borderWidth = 2
            mainVw.layer.borderColor = color.cgColor
            
            moreBtn.tintColor = color
            moreBtn.setTitleColor(color, for: .normal)
            
            if let image = moreBtn.imageView?.image {
                moreBtn.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        } else {
            let defaultColor = UIColor(hexString: "#076839") ?? .systemGreen
            leftVw.backgroundColor = defaultColor
            mainVw.layer.borderWidth = 2
            mainVw.layer.borderColor = defaultColor.cgColor
            moreBtn.tintColor = defaultColor
            moreBtn.setTitleColor(defaultColor, for: .normal)
        }
        
        if let eventInfo = event.eventInfo?.first,
           let imageUrlString = eventInfo.profileImage,
           let imageUrl = URL(string: imageUrlString) {
            imgVw?.loadImage(from: imageUrl)
        } else {
            imgVw?.image = UIImage(named: "Picture")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
