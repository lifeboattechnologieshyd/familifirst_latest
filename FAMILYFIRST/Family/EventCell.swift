//
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
    @IBOutlet weak var todayBtn: UIButton!
    @IBOutlet weak var nextmonthBtn: UIButton!
    @IBOutlet weak var descriptionTv: UITextView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var timeBtn: UIButton!
    
    var colorHexArray: [String] = [
        "#076839",
        "#390768",
        "#F18D95",
        "#0000FA",
        "#013366",
        "#FD8B00",
        "#8A0000",
        "#CC5500",
        "#008080",
        "#34B1A7",
        "#858381",
        "#8DB39E",
        "#4169E1",
        "#8B4513",
        "#DAA520"
        
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
         let nib = UINib(nibName: "ColorCell", bundle: nil)
        colorCollectionView.register(nib, forCellWithReuseIdentifier: "ColorCell")
        
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        
          
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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 24, height: 24)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10 // Gap between colors
    }
}

