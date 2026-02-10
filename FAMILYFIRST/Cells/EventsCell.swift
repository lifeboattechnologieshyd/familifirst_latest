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
        setupUI()
    }
    
    private func setupUI() {
        bgVw.addCardShadow()
        
        // Setup image views
        img1.layer.cornerRadius = 15
        img1.clipsToBounds = true
        
        img2.layer.cornerRadius = 15
        img2.clipsToBounds = true
        
        img3.layer.cornerRadius = 15
        img3.clipsToBounds = true
        
        // Setup more button
        moreBtn.layer.cornerRadius = 15
        moreBtn.clipsToBounds = true
        moreBtn.backgroundColor = UIColor.systemGray5
        moreBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        moreBtn.setTitleColor(.darkGray, for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        img1.layer.cornerRadius = img1.frame.height / 2
        img2.layer.cornerRadius = img2.frame.height / 2
        img3.layer.cornerRadius = img3.frame.height / 2
        moreBtn.layer.cornerRadius = moreBtn.frame.height / 2
    }
    
    func configure(with event: Event) {
        eventnameLbl.text = event.eventName
        dateLbl.text = event.dateFormatted
        dayLbl.text = event.daysToGo
        
        // Initially hide all user images and more button
        img1.isHidden = true
        img2.isHidden = true
        img3.isHidden = true
        moreBtn.isHidden = true
        
        guard let eventInfo = event.eventInfo else {
            print("No event info")
            return
        }
        
        let userCount = eventInfo.count
        print("Event: \(event.eventName), Users: \(userCount)")
        
        // Always show at least the more button for any users
        if userCount > 0 {
            // Show first 3 user images if available
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
            
            // Show more button for ANY number of users
            if userCount == 1 {
                // For single user, show "1" in the button
                moreBtn.isHidden = false
                moreBtn.setTitle("1", for: .normal)
            } else if userCount == 2 {
                // For 2 users, show "2" in the button
                moreBtn.isHidden = false
                moreBtn.setTitle("2", for: .normal)
            } else if userCount == 3 {
                // For 3 users, show "3" in the button
                moreBtn.isHidden = false
                moreBtn.setTitle("3", for: .normal)
            } else if userCount > 3 {
                // For more than 3 users, show how many additional
                moreBtn.isHidden = false
                let additionalCount = userCount - 3
                moreBtn.setTitle("+\(additionalCount)", for: .normal)
            }
            
            print("✅ Setting more button with: \(moreBtn.title(for: .normal) ?? "")")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        img1.isHidden = true
        img2.isHidden = true
        img3.isHidden = true
        moreBtn.isHidden = true
        moreBtn.setTitle("", for: .normal)
        eventnameLbl.text = ""
        dateLbl.text = ""
        dayLbl.text = ""
    }
    
    private func loadImage(for imageView: UIImageView, from urlString: String?) {
        if let urlString = urlString, let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
            }.resume()
        } else {
            imageView.image = UIImage(named: "Picture")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
