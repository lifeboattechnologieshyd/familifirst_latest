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
    
    // 👈 Female relations list
    private let femaleRelations = [
        "mother", "sister", "daughter", "aunt", "grandmother",
        "niece", "mother-in-law", "sister-in-law", "wife"
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        bgVw.addCardShadow()
        userImg.layer.cornerRadius = userImg.frame.height / 2
        userImg.clipsToBounds = true
        userImg.contentMode = .scaleAspectFill
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImg.layer.cornerRadius = userImg.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with member: FamilyMember) {
        nameLbl.text = member.fullName ?? "Unknown"
        relationLbl.text = member.relationType ?? ""
        mobileNumber = member.mobile?.stringValue ?? ""
        
        // 👈 Set image based on profile image or gender/relation
        if let imageUrl = member.profileImage, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
            loadImage(from: url, member: member)
        } else {
            setDefaultImage(for: member)
        }
    }
    
    // 👈 Set default image based on gender/relation
    private func setDefaultImage(for member: FamilyMember) {
        if isFemale(member: member) {
            userImg.image = UIImage(named: "femaleicon")  // 👈 Female icon
        } else {
            userImg.image = UIImage(named: "userImage")   // 👈 Male icon
        }
    }
    
    // 👈 Check if member is female
    private func isFemale(member: FamilyMember) -> Bool {
        // First check explicit gender from API
        if let gender = member.gender?.lowercased() {
            if gender == "female" || gender == "f" {
                return true
            } else if gender == "male" || gender == "m" {
                return false
            }
        }
        
        // If gender not available, check relation type
        if let relation = member.relationType?.lowercased() {
            return femaleRelations.contains(relation)
        }
        
        return false // Default to male icon
    }
    
    private func loadImage(from url: URL, member: FamilyMember) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    self?.userImg.image = image
                } else {
                    // If image fails to load, use default based on gender
                    self?.setDefaultImage(for: member)
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
