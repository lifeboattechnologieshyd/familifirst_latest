//
//  BannerCell.swift
//  FamilyFirst
//
//  Created by Lifeboat on 10/01/26.
//

import UIKit

class BannerCell: UITableViewCell {
    
    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var calenderTitleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var calenderPromptLbl: UILabel!
    
    // ✅ ADD: Callback for cell tap
    var didTapBanner: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTapGesture()
    }
    
    // ✅ ADD: Setup tap gesture
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bannerTapped))
        contentView.addGestureRecognizer(tapGesture)
        contentView.isUserInteractionEnabled = true
    }
    
    // ✅ ADD: Handle tap
    @objc private func bannerTapped() {
        print("📅 BannerCell tapped!")
        didTapBanner?()
    }
    
    func configure(with calendarData: CalendarData?) {
        guard let data = calendarData else {
            // ✅ Handle nil case - show today's date
            let today = Date()
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMM"
            monthLbl.text = monthFormatter.string(from: today).uppercased()
            
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "dd"
            dateLbl.text = dayFormatter.string(from: today)
            
            calenderPromptLbl.text = "No events today"
            return
        }
        
        // Date Parsing
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = dateFormatter.date(from: data.date) {
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMM"
            monthLbl.text = monthFormatter.string(from: date).uppercased()

            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "dd"
            dateLbl.text = dayFormatter.string(from: date)
        } else {
            monthLbl.text = ""
            dateLbl.text = ""
        }
        
        // Mapping API Description -> Prompt/Body Label
        calenderPromptLbl.text = data.prompt
    }
    
    // ✅ ADD: Reset callback on reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        didTapBanner = nil
        monthLbl.text = ""
        dateLbl.text = ""
        calenderPromptLbl.text = ""
    }
}
