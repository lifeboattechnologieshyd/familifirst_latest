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

  
        // Configure the view for the selected state
    }
    
