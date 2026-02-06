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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with calendarData: CalendarData?) {
        guard let data = calendarData else { return }
        
        // Parse date string "dd-MM-yyyy"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = dateFormatter.date(from: data.date) {
            // Get Month Name (e.g. "February")
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMMM"
            monthLbl.text = monthFormatter.string(from: date)
            
            // Get Day (e.g. "04")
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "dd"
            dateLbl.text = dayFormatter.string(from: date)
        } else {
            monthLbl.text = ""
            dateLbl.text = ""
        }
        
        calenderTitleLbl.text = "Today's Prompt"
        calenderPromptLbl.text = data.prompt
    }
}
