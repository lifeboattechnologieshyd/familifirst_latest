
//  EventCell.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 17/01/26.
//

import UIKit

class EventCell: UITableViewCell {
    
    @IBOutlet weak var colorCollectionView: UICollectionView!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var eventTf: UITextField!
    @IBOutlet weak var tomorrowbtn: UIButton!
    @IBOutlet weak var dateTf: UITextField!
    @IBOutlet weak var timeTf: UITextField!
    @IBOutlet weak var todayBtn: UIButton!
    @IBOutlet weak var nextmonthBtn: UIButton!
    @IBOutlet weak var descriptionTv: UITextView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var timeBtn: UIButton!
    
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    
    var selectedColorHex: String = "#076839"
    
    var colorHexArray: [String] = [
        "#076839", "#390768", "#F18D95", "#0000FA", "#013366",
        "#FD8B00", "#8A0000", "#CC5500", "#008080", "#34B1A7",
        "#858381", "#8DB39E", "#4169E1", "#8B4513", "#DAA520"
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dateTf.addCardShadow()
        timeTf.addCardShadow()
        descriptionTv.addCardShadow()
        eventTf.addCardShadow()
        
         dateTf.textColor = .clear
        dateTf.tintColor = .clear
        
        timeTf.textColor = .clear
        timeTf.tintColor = .clear
        
        let nib = UINib(nibName: "ColorCell", bundle: nil)
        colorCollectionView.register(nib, forCellWithReuseIdentifier: "ColorCell")
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        
        setupDatePicker()
        setupTimePicker()
        
        dateBtn.addTarget(self, action: #selector(openDatePicker), for: .touchUpInside)
        timeBtn.addTarget(self, action: #selector(openTimePicker), for: .touchUpInside)
    }

    func setupDatePicker() {
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneDateAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneBtn], animated: true)
        
        dateTf.inputAccessoryView = toolbar
        dateTf.inputView = datePicker
    }
    
    @objc func openDatePicker() {
        dateTf.becomeFirstResponder()
    }
    
    @objc func doneDateAction() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        dateTf.text = formatter.string(from: datePicker.date)
        dateLbl.text = formatter.string(from: datePicker.date)
        
        self.endEditing(true)
    }
    
    func setupTimePicker() {
        timePicker.datePickerMode = .time
        if #available(iOS 13.4, *) {
            timePicker.preferredDatePickerStyle = .wheels
        }
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTimeAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneBtn], animated: true)
        
        timeTf.inputAccessoryView = toolbar
        timeTf.inputView = timePicker
    }
    
    @objc func openTimePicker() {
        timeTf.becomeFirstResponder()
    }
    
    @objc func doneTimeAction() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        timeTf.text = formatter.string(from: timePicker.date)
        timeLbl.text = formatter.string(from: timePicker.date)
        
        self.endEditing(true)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension EventCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorHexArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
        let hexString = colorHexArray[indexPath.row]
        cell.colorView.backgroundColor = UIColor(hexString: hexString)
        
        if hexString == selectedColorHex {
            cell.layer.borderWidth = 3
            cell.layer.borderColor = UIColor.lightGray.cgColor
        } else {
            cell.layer.borderWidth = 0
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 30, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedColorHex = colorHexArray[indexPath.row]
        collectionView.reloadData()
    }
}
