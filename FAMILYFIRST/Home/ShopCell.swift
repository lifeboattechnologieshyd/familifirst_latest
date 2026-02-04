//
//  ShopCell.swift
//  FamilyFirst
//
//  Created by Lifeboat on 10/01/26.
//

import UIKit

class ShopCell: UITableViewCell {

    @IBOutlet weak var viewAll: UIButton!
    @IBOutlet weak var logoutbtn: UIButton!
    @IBOutlet weak var colVw: UICollectionView!
    
    var didTapLogout: (() -> Void)?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        colVw.delegate = self
        colVw.dataSource = self
        
        let nib = UINib(nibName: "ShopCollectionViewCell", bundle: nil)
        colVw.register(nib, forCellWithReuseIdentifier: "ShopCollectionViewCell")
        
        colVw.reloadData()
        logoutbtn.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
            }
            
            @objc private func logoutTapped() {
                didTapLogout?()
    }
}
extension ShopCell: UICollectionViewDelegate,
                    UICollectionViewDataSource,
                    UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView,cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShopCollectionViewCell",for: indexPath) as! ShopCollectionViewCell
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 200)
    }
}
