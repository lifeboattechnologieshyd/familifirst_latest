import UIKit

class ShopCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var productLbl: UILabel!
    @IBOutlet weak var tagVw: UIView!
    @IBOutlet weak var tagLbl: UILabel!
    @IBOutlet weak var tagVwWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTagView()
    }
    
    private func setupTagView() {
        tagVw.layer.cornerRadius = 4
        tagVw.clipsToBounds = true
    }
    
    func configure(with product: Product) {
        productLbl.text = product.itemName
        
        if let discountTag = product.discountTag, !discountTag.isEmpty {
            tagLbl.text = discountTag
            tagVw.isHidden = false
            
            let labelWidth = discountTag.size(withAttributes: [
                .font: tagLbl.font as Any
            ]).width
            
            tagVwWidthConstraint.constant = ceil(labelWidth) + 20
            
            contentView.layoutIfNeeded()
            
        } else {
            tagLbl.text = ""
            tagVw.isHidden = true
        }
        
        imgVw.setImage(url: product.thumbnailImage, placeHolderImage: "FF Logo")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgVw.image = UIImage(named: "FF Logo")
        productLbl.text = ""
        tagLbl.text = ""
        tagVw.isHidden = false
        tagVwWidthConstraint.constant = 50
    }
}
