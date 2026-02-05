//
//  CalenderCell.swift
//  FamilyFirst
//
//  Created by Lifeboat on 10/01/26.
//

import UIKit

class CalenderCell: UITableViewCell {

    @IBOutlet weak var viewallBtn: UIButton!
    @IBOutlet weak var colVw: UICollectionView!
    
    var didTapViewAll: (() -> Void)?
    var didSelectCalenderItem: ((Int) -> Void)?
    
    var events: [Event] = [] {
        didSet {
            colVw.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        colVw.delegate = self
        colVw.dataSource = self
        
        let nib = UINib(nibName: "CalenderCollectionCell", bundle: nil)
        colVw.register(nib, forCellWithReuseIdentifier: "CalenderCollectionCell")
        
        colVw.reloadData()
        
        viewallBtn.addTarget(self, action: #selector(viewAllBtnTapped), for: .touchUpInside)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        didTapViewAll = nil
        didSelectCalenderItem = nil
        events = []
    }
    
    @objc private func viewAllBtnTapped() {
        didTapViewAll?()
    }
}

extension CalenderCell: UICollectionViewDelegate,
                        UICollectionViewDataSource,
                        UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return min(events.count, 7)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CalenderCollectionCell",
            for: indexPath
        ) as! CalenderCollectionCell
        
        if indexPath.item < events.count {
            let event = events[indexPath.item]
            cell.configure(with: event)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 196, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        didSelectCalenderItem?(indexPath.item)
    }
}
