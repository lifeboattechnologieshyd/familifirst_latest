//
//  ColorCell.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 17/01/26.
//

import UIKit

class ColorCell: UICollectionViewCell {
    
    @IBOutlet weak var colorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        colorView.layer.cornerRadius = 6
        colorView.clipsToBounds = true
    }
}
