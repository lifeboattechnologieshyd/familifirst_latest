//
//  EditCell.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 10/02/26.
//
import UIKit

class EditCell: UITableViewCell {
    
    @IBOutlet weak var relationTf: UITextField!
    @IBOutlet weak var notesTv: UITextView!
    @IBOutlet weak var dateofbirthTf: UITextField!
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var mobilenumberTf: UITextField!
    
    private let datePicker = UIDatePicker()
    private let relationPicker = UIPickerView()
    private let relations = ["Father", "Mother", "Brother", "Sister", "Spouse", "Son", "Daughter", "Cousin", "Uncle", "Aunt", "Grandfather", "Grandmother", "Friend", "Other"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupDatePicker()
        setupRelationPicker()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameTf.text = ""
        mobilenumberTf.text = ""
        emailTf.text = ""
        relationTf.text = ""
        dateofbirthTf.text = ""
        notesTv.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameTf?.setNeedsDisplay()
        mobilenumberTf?.setNeedsDisplay()
        emailTf?.setNeedsDisplay()
        relationTf?.setNeedsDisplay()
        dateofbirthTf?.setNeedsDisplay()
        notesTv?.setNeedsDisplay()
    }

    private func setupUI() {
        notesTv.addCardShadow()
        nameTf.addCardShadow()
        mobilenumberTf.addCardShadow()
        dateofbirthTf.addCardShadow()
        emailTf.addCardShadow()
        relationTf.addCardShadow()
        
        notesTv.layer.cornerRadius = 8
        notesTv.layer.borderWidth = 1
        notesTv.layer.borderColor = UIColor.lightGray.cgColor
        notesTv.textColor = .black
        notesTv.font = UIFont.systemFont(ofSize: 14)
        
        mobilenumberTf.keyboardType = .phonePad
        emailTf.keyboardType = .emailAddress
        
        nameTf.textColor = .black
        mobilenumberTf.textColor = .black
        emailTf.textColor = .black
        relationTf.textColor = .black
        dateofbirthTf.textColor = .black
    }
    
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dateDonePressed))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        
        dateofbirthTf.inputView = datePicker
        dateofbirthTf.inputAccessoryView = toolbar
    }
    
    private func setupRelationPicker() {
        relationPicker.delegate = self
        relationPicker.dataSource = self
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(relationDonePressed))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        
        relationTf.inputView = relationPicker
        relationTf.inputAccessoryView = toolbar
    }
    
    @objc private func dateDonePressed() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dateofbirthTf.text = formatter.string(from: datePicker.date)
        dateofbirthTf.resignFirstResponder()
    }
    
    @objc private func relationDonePressed() {
        let row = relationPicker.selectedRow(inComponent: 0)
        relationTf.text = relations[row]
        relationTf.resignFirstResponder()
    }
    
    func configure(with member: FamilyMember) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.nameTf.text = member.fullName ?? ""
            
            if let mobileType = member.mobile {
                self.mobilenumberTf.text = mobileType.stringValue
            } else {
                self.mobilenumberTf.text = ""
            }
            
            self.emailTf.text = member.email ?? ""
            self.relationTf.text = member.relationType ?? ""
            
            if let dob = member.dateOfBirth, !dob.isEmpty {
                self.dateofbirthTf.text = dob
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                if let date = formatter.date(from: dob) {
                    self.datePicker.date = date
                }
            } else {
                self.dateofbirthTf.text = ""
            }
            
            if let notes = member.notes, let hobbies = notes.hobbies, !hobbies.isEmpty {
                self.notesTv.text = hobbies.joined(separator: ", ")
                self.notesTv.textColor = .black
            } else {
                self.notesTv.text = ""
            }
            
            if let relation = member.relationType, let index = self.relations.firstIndex(of: relation) {
                self.relationPicker.selectRow(index, inComponent: 0, animated: false)
            }
            
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    func getFormData() -> [String: Any]? {
        guard let name = nameTf.text, !name.isEmpty else { return nil }
        guard let mobile = mobilenumberTf.text, mobile.count == 10 else { return nil }
        guard let relation = relationTf.text, !relation.isEmpty else { return nil }
        
        var params: [String: Any] = [
            "full_name": name,
            "mobile": mobile,
            "relation_type": relation
        ]
        
        if let email = emailTf.text, !email.isEmpty {
            params["email"] = email
        }
        
        if let dob = dateofbirthTf.text, !dob.isEmpty {
            params["date_of_birth"] = dob
        }
        
        if let notes = notesTv.text, !notes.isEmpty {
            let hobbies = notes.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            params["notes"] = ["hobbies": hobbies]
        }
        
        return params
    }
}

extension EditCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return relations.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return relations[row]
    }
}
