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
    @IBOutlet weak var eventLbl: UILabel!
    @IBOutlet weak var mainVw: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with event: Event) {
        dateLbl.text = event.dateFormatted
        dayLbl.text = event.daysToGo
        eventLbl.text = event.eventName
        
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
