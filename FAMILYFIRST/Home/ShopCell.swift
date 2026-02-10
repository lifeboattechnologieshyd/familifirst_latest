import UIKit

class ShopCell: UITableViewCell {

    @IBOutlet weak var viewAll: UIButton!
    @IBOutlet weak var logoutbtn: UIButton!
    @IBOutlet weak var colVw: UICollectionView!
    
    var didTapLogout: (() -> Void)?
    var didTapViewAll: (() -> Void)?
    var didSelectProduct: ((Product) -> Void)?
    
    var products: [Product] = [] {
        didSet {
            colVw.reloadData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        colVw.delegate = self
        colVw.dataSource = self
        
        let nib = UINib(nibName: "ShopCollectionViewCell", bundle: nil)
        colVw.register(nib, forCellWithReuseIdentifier: "ShopCollectionViewCell")
        
        colVw.reloadData()
        logoutbtn.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        viewAll.addTarget(self, action: #selector(viewAllTapped), for: .touchUpInside)
    }
    
    @objc private func logoutTapped() {
        didTapLogout?()
    }
    
    @objc private func viewAllTapped() {
        didTapViewAll?()
    }
}

extension ShopCell: UICollectionViewDelegate,
                    UICollectionViewDataSource,
                    UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return min(products.count, 10)
    }

    func collectionView(_ collectionView: UICollectionView,cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShopCollectionViewCell",for: indexPath) as! ShopCollectionViewCell
        let product = products[indexPath.row]
        cell.configure(with: product)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = products[indexPath.row]
        didSelectProduct?(product)
    }
}
