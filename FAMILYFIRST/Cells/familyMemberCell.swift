//
//  familyMemberCell.swift
//  FamilyFirst
//
//  Created by Lifeboat on 09/01/26.
//

import UIKit

class familyMemberCell: UITableViewCell {

    @IBOutlet weak var relationLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var bgVw: UIView!
    @IBOutlet weak var whatsappBtn: UIButton!
    @IBOutlet weak var userImg: UIImageView!
    
    private var mobileNumber: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgVw.addCardShadow()
        userImg.layer.cornerRadius = userImg.frame.height / 2
        userImg.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with member: FamilyMember) {
        nameLbl.text = member.fullName ?? "Unknown"
        relationLbl.text = member.relationType ?? ""
        mobileNumber = member.mobile?.stringValue ?? ""
        
        if let imageUrl = member.profileImage, let url = URL(string: imageUrl) {
            loadImage(from: url)
        } else {
            userImg.image = UIImage(systemName: "person.circle.fill")
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
    
    @IBAction func callBtnTapped(_ sender: UIButton) {
        guard !mobileNumber.isEmpty else { return }
        if let url = URL(string: "tel://\(mobileNumber)") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func whatsappBtnTapped(_ sender: UIButton) {
        guard !mobileNumber.isEmpty else { return }
        let whatsappURL = "https://wa.me/91\(mobileNumber)"
        if let url = URL(string: whatsappURL) {
            UIApplication.shared.open(url)
        }
    }
}
