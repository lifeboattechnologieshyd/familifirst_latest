//
//  UserCell.swift
//  FamilyFirst
//
//  Created by Lifeboat on 09/01/26.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var shareBTn: UIButton!
    @IBOutlet weak var referVw: UIView!
    @IBOutlet weak var referalcodeLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var bgVw: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgVw.addCardShadow()
        userImg.layer.cornerRadius = userImg.frame.height / 2
        userImg.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        referVw.addDashedBorder()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with member: FamilyMember) {
        nameLbl.text = member.fullName ?? "User"
        
        // Check if string exists AND is not empty
        if let imageUrl = member.profileImage, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
            loadImage(from: url)
        } else {
            // Set your default asset image here
            userImg.image = UIImage(named: "Picture")
        }
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.userImg.image = image
                }
            }
        }.resume()
    }
}
