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
    @IBOutlet weak var viewone: UIView!
    @IBOutlet weak var mailBtn: UIButton!
    @IBOutlet weak var notesFont: UILabel!
    @IBOutlet weak var notesLbl: UILabel!
    @IBOutlet weak var mailCopy: UIButton!
    @IBOutlet weak var relationLbl: UILabel!
    @IBOutlet weak var viewtwo: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    
    var onShowToast: ((String) -> Void)?
    var onBackTapped: (() -> Void)?
    var onEditTapped: (() -> Void)?
    
    private var mobileNumber: String = ""
    private var email: String = ""
    
    private let femaleRelations = [
        "mother", "sister", "daughter", "aunt", "grandmother",
        "niece", "mother-in-law", "sister-in-law", "wife"
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        phoneBgVw.addCardShadow()
        mailBgVw.addCardShadow()
        imgVw.layer.cornerRadius = imgVw.frame.height / 2
        imgVw.clipsToBounds = true
        imgVw.contentMode = .scaleAspectFill
        notesFont.font = UIFont(name: "Lexend-SemiBold", size: 16)
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgVw.layer.cornerRadius = imgVw.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        onBackTapped?()
    }
    
    @IBAction func editBtnTapped(_ sender: UIButton) {
        print("Edit button tapped in DetailsCell")
        onEditTapped?()
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
    
    // 👈 Updated configure method with hasNotes parameter
    func configure(with member: FamilyMember, hasNotes: Bool = true) {
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
        
        // 👈 Hide/Show notes section based on hasNotes
        configureNotesVisibility(hasNotes: hasNotes)
        
        if let imageUrl = member.profileImage, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
            loadImage(from: url, member: member)
        } else {
            setDefaultImage(for: member)
        }
    }
    
    // 👈 New method to configure notes visibility
    private func configureNotesVisibility(hasNotes: Bool) {
        if hasNotes {
            // Show notes section
            notesLbl.isHidden = false
            notesFont.isHidden = false
            viewone.isHidden = false
            viewtwo.isHidden = false
        } else {
            // Hide notes section
            notesLbl.isHidden = true
            notesFont.isHidden = true
            viewone.isHidden = true
            viewtwo.isHidden = true
        }
    }
    
    private func setDefaultImage(for member: FamilyMember) {
        if isFemale(member: member) {
            imgVw.image = UIImage(named: "femaleicon")
        } else {
            imgVw.image = UIImage(named: "userImage")
        }
    }
    
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
                    self?.imgVw.image = image
                } else {
                    // If image fails to load, use default based on gender
                    self?.setDefaultImage(for: member)
                }
            }
        }.resume()
    }
}
