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
    @IBOutlet weak var youLbl: UILabel!
    @IBOutlet weak var copyLbl: UILabel!
    @IBOutlet weak var shareLbl: UILabel!
    @IBOutlet weak var referLbl: UILabel!
    @IBOutlet weak var referalcodeLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var bgVw: UIView!
    
    var onEditTapped: (() -> Void)?
    var onCopyTapped: (() -> Void)?
    var onShareTapped: (() -> Void)?
    
    private var referralCode: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgVw.addCardShadow()
        userImg.layer.cornerRadius = userImg.frame.height / 2
        userImg.clipsToBounds = true
        selectionStyle = .none
        
        editBtn.addTarget(self, action: #selector(editBtnTapped), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        referVw.addDashedBorder()
        shareLbl.font = UIFont(name: "Lexend-Regular", size: 14)
        copyLbl.font = UIFont(name: "Lexend-Light", size: 14)
        youLbl.font = UIFont(name: "Lexend-Light", size: 14)
        referLbl.font = UIFont(name: "Lexend-Light", size: 14)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc private func editBtnTapped() {
        onEditTapped?()
    }
    
    @IBAction func copyBtnTapped(_ sender: UIButton) {
        if !referralCode.isEmpty {
            UIPasteboard.general.string = referralCode
            onCopyTapped?()
        }
    }
    
    @IBAction func shareBtnTapped(_ sender: UIButton) {
        onShareTapped?()
    }
    
    func configure(with member: FamilyMember) {
        nameLbl.text = member.fullName ?? "User"
        
        // Show referral code if available (fetch from UserDetails API)
        // For now, show N/A - will be updated after profile fetch
        referalcodeLbl.text = "N/A"
        
        if let imageUrl = member.profileImage, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
            loadImage(from: url)
        } else {
            userImg.image = UIImage(named: "Picture")
        }
    }
    
    // Configure with UserDetails (for showing referral code)
    func configureWithUserDetails(_ user: UserDetails) {
        // Name
        if let firstName = user.firstName, !firstName.isEmpty {
            if let lastName = user.lastName, !lastName.isEmpty {
                nameLbl.text = "\(firstName) \(lastName)"
            } else {
                nameLbl.text = firstName
            }
        } else if let lastName = user.lastName, !lastName.isEmpty {
            nameLbl.text = lastName
        } else {
            nameLbl.text = user.username ?? "User"
        }
        
        // Referral Code
        referralCode = user.referralCode ?? ""
        referalcodeLbl.text = user.referralCode ?? "N/A"
        
        // Profile Image
        if let imageUrl = user.profileImage, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
            loadImage(from: url)
        } else {
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
