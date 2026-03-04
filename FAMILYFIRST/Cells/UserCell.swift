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
    @IBOutlet weak var editPicture: UIButton!
    @IBOutlet weak var referLbl: UILabel!
    @IBOutlet weak var copyBtn: UIButton!
    @IBOutlet weak var referalcodeLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var bgVw: UIView!
    
    var onEditTapped: (() -> Void)?
    var onCopyTapped: (() -> Void)?
    var onShareTapped: (() -> Void)?
    var onEditPictureTapped: (() -> Void)?
    
    private var referralCode: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgVw.addCardShadow()
        userImg.layer.cornerRadius = userImg.frame.height / 2
        userImg.clipsToBounds = true
        userImg.contentMode = .scaleAspectFill
        selectionStyle = .none
        
        editBtn.addTarget(self, action: #selector(editBtnTapped), for: .touchUpInside)
        editPicture.addTarget(self, action: #selector(editPictureBtnTapped), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        referVw.addDashedBorder()
        youLbl.font = UIFont(name: "Lexend-Light", size: 14)
        referLbl.font = UIFont(name: "Lexend-Light", size: 14)
        
        // Ensure circular image
        userImg.layer.cornerRadius = userImg.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc private func editBtnTapped() {
        onEditTapped?()
    }
    
    @objc private func editPictureBtnTapped() {
        onEditPictureTapped?()
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
        referalcodeLbl.text = "N/A"
        
        if let savedImage = UserManager.shared.profileImage {
            userImg.image = savedImage
        } else if let imageUrl = member.profileImage, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
            loadImage(from: url)
        } else {
            userImg.image = UIImage(named: "Picture")
        }
    }
    
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
        
        if let savedImage = UserManager.shared.profileImage {
            userImg.image = savedImage
        } else if let imageUrl = user.profileImage, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
            loadImage(from: url)
        } else {
            userImg.image = UIImage(named: "Picture")
        }
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    // Only set if no local image saved
                    if UserManager.shared.profileImage == nil {
                        self?.userImg.image = image
                    }
                }
            }
        }.resume()
    }
    
    func updateProfileImage(_ image: UIImage) {
        UIView.transition(with: userImg, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.userImg.image = image
        }, completion: nil)
        
        // Bounce animation
        UIView.animate(withDuration: 0.15, animations: {
            self.userImg.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.userImg.transform = .identity
            }
        }
    }
}
