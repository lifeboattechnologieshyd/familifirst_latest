//
//  DetailsCell.swift
//  FamilyFirst
//
//  Created by Lifeboat on 10/01/26.
//

import UIKit

class DetailsCell: UITableViewCell {

    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var dateofbirthLbl: UILabel!
    @IBOutlet weak var phoneBgVw: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var phonenoCopy: UIButton!
    @IBOutlet weak var mailBgVw: UIView!
    @IBOutlet weak var dateofbirthEdit: UIButton!
    @IBOutlet weak var mailLbl: UILabel!
    @IBOutlet weak var whatsappBtn: UIButton!
    @IBOutlet weak var phonenumberLbl: UILabel!
    @IBOutlet weak var mailBtn: UIButton!
    @IBOutlet weak var mailCopy: UIButton!
    @IBOutlet weak var relationLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    
    var onShowToast: ((String) -> Void)?
    var onBackTapped: (() -> Void)?

    
    private var mobileNumber: String = ""
    private var email: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        phoneBgVw.addCardShadow()
        mailBgVw.addCardShadow()
        imgVw.layer.cornerRadius = imgVw.frame.height / 2
        imgVw.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func backBtnTapped(_ sender: UIButton) {
            onBackTapped?()
        }
    
    func configure(with member: FamilyMember) {
        nameLbl.text = member.fullName ?? "N/A"
        relationLbl.text = member.relationType ?? "N/A"
        
        mobileNumber = member.mobile?.stringValue ?? ""
        phonenumberLbl.text = mobileNumber.isEmpty ? "N/A" : mobileNumber
        
        email = member.email ?? ""
        mailLbl.text = email.isEmpty ? "N/A" : email
        
        if let dob = member.dateOfBirth {
            dateofbirthLbl.text = dob
        } else {
            dateofbirthLbl.text = "N/A"
        }
        
        if let imageUrl = member.profileImage, let url = URL(string: imageUrl) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.imgVw.image = image
                    }
                }
            }.resume()
        } else {
            imgVw.image = UIImage(systemName: "person.circle.fill")
        }
    }
    
    @IBAction func callBtnTapped(_ sender: UIButton) {
        guard !mobileNumber.isEmpty, let url = URL(string: "tel://\(mobileNumber)") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func whatsappBtnTapped(_ sender: UIButton) {
        guard !mobileNumber.isEmpty, let url = URL(string: "https://wa.me/91\(mobileNumber)") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func phonenoCopyTapped(_ sender: UIButton) {
        guard !mobileNumber.isEmpty else { return }
        UIPasteboard.general.string = mobileNumber
        onShowToast?("Mobile number copied successfully")
    }
    
    @IBAction func mailBtnTapped(_ sender: UIButton) {
        guard !email.isEmpty, let url = URL(string: "mailto:\(email)") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func mailCopyTapped(_ sender: UIButton) {
        guard !email.isEmpty else { return }
        UIPasteboard.general.string = email
        onShowToast?("Email copied successfully")
    }
}
