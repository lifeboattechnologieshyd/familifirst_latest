//
//  CalenderCollectionCell.swift
//  FamilyFirst
//
//  Created by Lifeboat on 10/01/26.
//
import UIKit

class CalenderCollectionCell: UICollectionViewCell {

    @IBOutlet weak var calenderLbl: UILabel!
    @IBOutlet weak var bgVw: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgVw.addCardShadow()
        bgVw.layer.masksToBounds = true
    }
    
    func configure(with event: Event) {
        calenderLbl.text = event.eventName
        
        if let eventDate = event.eventDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM"
            dateLbl.text = formatter.string(from: eventDate)
        } else {
            dateLbl.text = event.dateFormatted
        }
    }
}
