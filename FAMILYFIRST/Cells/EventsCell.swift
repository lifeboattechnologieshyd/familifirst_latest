//
//  EventsCell.swift
//  FamilyFirst
//
//  Created by Lifeboat on 10/01/26.
//

import UIKit

class EventsCell: UITableViewCell {

    @IBOutlet weak var bgVw: UIView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var eventnameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with event: Event) {
        eventnameLbl.text = event.eventName
        dateLbl.text = event.dateFormatted
        dayLbl.text = event.daysToGo
        
        img1.isHidden = true
        img2.isHidden = true
        img3.isHidden = true
        moreBtn.isHidden = true
        
        guard let eventInfo = event.eventInfo else { return }
        
        let userCount = eventInfo.count
        
        if userCount >= 1 {
            img1.isHidden = false
            loadImage(for: img1, from: eventInfo[0].profileImage)
        }
        
        if userCount >= 2 {
            img2.isHidden = false
            loadImage(for: img2, from: eventInfo[1].profileImage)
        }
        
        if userCount >= 3 {
            img3.isHidden = false
            loadImage(for: img3, from: eventInfo[2].profileImage)
        }
        
        if userCount > 3 {
            moreBtn.isHidden = false
            moreBtn.setTitle("+\(userCount - 3)", for: .normal)
        }
    }
    
    private func loadImage(for imageView: UIImageView, from urlString: String?) {
        if let urlString = urlString, let url = URL(string: urlString) {
            imageView.loadImage(from: url)
        } else {
            imageView.image = UIImage(named: "Picture")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
