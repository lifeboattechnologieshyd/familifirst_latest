//
//  FeelsCollectionViewCell.swift
//  FamilyFirst
//
//  Created by Lifeboat on 14/01/26.
//

import UIKit

class FeelsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgVw: UIImageView!
    
    // Make sure to init this just in case
    var playClicked: ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Ensure the image doesn't steal touches from the button
        imgVw.isUserInteractionEnabled = false
        
        // Ensure the play button is brought to front
        self.contentView.bringSubviewToFront(btnPlay)
    }

    @IBAction func onClickPlay(_ sender: UIButton) {
        print("Play button tapped for index: \(sender.tag)") // Debug print
        
        // Use '?' instead of '!' to prevent crashes
        self.playClicked?(sender.tag)
    }
}
