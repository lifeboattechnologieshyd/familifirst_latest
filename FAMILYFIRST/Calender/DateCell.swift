//
//  DateCell.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 07/03/26.
//

import UIKit

class DateCell: UICollectionViewCell {
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var lblMonth: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 8
        bgView.clipsToBounds = true
    }
}
