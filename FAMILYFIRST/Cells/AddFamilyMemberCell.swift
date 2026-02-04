//
//  AddFamilyMemberCell.swift
//  FamilyFirst
//
//  Created by Lifeboat on 09/01/26.
//

import UIKit

class AddFamilyMemberCell: UITableViewCell {

    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var mobilenumberTf: UITextField!
    @IBOutlet weak var notesTv: UITextView!
    @IBOutlet weak var dateofbirthTf: UITextField!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var relationTf: UITextField!
    
    private let datePicker = UIDatePicker()
    private let relationPicker = UIPickerView()
    private let relations = ["Father", "Mother", "Brother", "Sister", "Spouse", "Son", "Daughter", "Cousin", "Uncle", "Aunt", "Grandfather", "Grandmother", "Friend", "Other"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupDatePicker()
        setupRelationPicker()
    }

    private func setupUI() {
        notesTv.addCardShadow()
        nameTf.addCardShadow()
        mobilenumberTf.addCardShadow()
        dateofbirthTf.addCardShadow()
        emailTf.addCardShadow()
        relationTf.addCardShadow()
        
        mobilenumberTf.keyboardType = .phonePad
        emailTf.keyboardType = .emailAddress
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
    
    func getFormData() -> [String: Any]? {
        guard let name = nameTf.text, !name.isEmpty else { return nil }
        guard let mobile = mobilenumberTf.text, mobile.count == 10 else { return nil }
        guard let relation = relationTf.text, !relation.isEmpty else { return nil }
        
        var params: [String: Any] = [
            "full_name": name,
            "mobile": mobile,
            "relation_type": relation,
            "status": "Awaiting"
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

extension AddFamilyMemberCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { relations.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { relations[row] }
}
