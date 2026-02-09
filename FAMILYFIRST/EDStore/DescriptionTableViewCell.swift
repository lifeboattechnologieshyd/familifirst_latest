//
//  DescriptionTableViewCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 23/10/25.
//

import UIKit

class DescriptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var interestingLbl: UILabel!
    @IBOutlet weak var mrpLbl: UILabel!
    @IBOutlet weak var strikeOutPrice: UILabel!
    @IBOutlet weak var descriptionTv: UITextView!
    @IBOutlet weak var strikeLineImg: UIImageView!
    @IBOutlet weak var variant1: UILabel!
    @IBOutlet weak var variant2: UILabel!
    @IBOutlet weak var aboutLbl: UILabel!
    @IBOutlet weak var blueVw2: UIView!
    @IBOutlet weak var blueVw: UIView!
    @IBOutlet weak var sizesLbl: UILabel!
    @IBOutlet weak var offLbl: UILabel!
    @IBOutlet weak var amount2Lbl: UILabel!
    
    @IBOutlet weak var blueVwWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var blueVw2WidthConstraint: NSLayoutConstraint!
    
    private var strikeThroughLine: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    private func setupViews() {
        variant1.numberOfLines = 0
        variant1.lineBreakMode = .byWordWrapping
        
        variant2.numberOfLines = 0
        variant2.lineBreakMode = .byWordWrapping
        
        blueVw.clipsToBounds = true
        blueVw2.clipsToBounds = true
        
        // ✅ Hide variant2 and blueVw2 by default
        blueVw2.isHidden = true
        variant2.text = ""
        
        interestingLbl.numberOfLines = 0
        descriptionTv.isEditable = false
        descriptionTv.isScrollEnabled = false
        
        strikeLineImg?.isHidden = true
    }
    
    func addStrikethrough(to label: UILabel, show: Bool) {
        strikeThroughLine?.removeFromSuperview()
        
        guard show, let text = label.text, !text.isEmpty else {
            return
        }
        
        let lineView = UIView()
        lineView.backgroundColor = .black
        lineView.translatesAutoresizingMaskIntoConstraints = false
        label.superview?.addSubview(lineView)
        
        NSLayoutConstraint.activate([
            lineView.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            lineView.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: label.trailingAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1.5)
        ])
        
        strikeThroughLine = lineView
    }
    
    func setStrikethroughPrice(_ price: String, shouldStrike: Bool) {
        if shouldStrike {
            let attributedString = NSMutableAttributedString(string: price)
            attributedString.addAttribute(
                .strikethroughStyle,
                value: 2,
                range: NSRange(location: 0, length: attributedString.length)
            )
            attributedString.addAttribute(
                .strikethroughColor,
                value: UIColor.black,
                range: NSRange(location: 0, length: attributedString.length)
            )
            strikeOutPrice.attributedText = attributedString
        } else {
            strikeOutPrice.text = price
        }
    }
    
    // ✅ Configure only ONE variant in blueVw
    func configureVariantViews(with product: Product) {
        
        // ✅ Always hide variant2 and blueVw2
        variant2.text = ""
        blueVw2.isHidden = true
        
        if let variants = product.variants, !variants.isEmpty {
            let variantArray = Array(variants)
            
            let maxWidth = UIScreen.main.bounds.width - 40
            let padding: CGFloat = 24
            
            // ✅ Show only first variant in blueVw
            if variantArray.indices.contains(0) {
                let (key, values) = variantArray[0]
                let variantText = "\(key.capitalized): \(values.joined(separator: ", "))"
                variant1.text = variantText
                blueVw.isHidden = false
                
                // Calculate required width
                let textWidth = calculateTextWidth(for: variantText, font: variant1.font, maxWidth: maxWidth - padding)
                let viewWidth = textWidth + padding
                
                // Set width constraint
                blueVwWidthConstraint.constant = min(viewWidth, maxWidth)
                
                print("📏 BlueVw width: \(blueVwWidthConstraint.constant)")
                
            } else {
                variant1.text = ""
                blueVw.isHidden = true
            }
            
        } else {
            variant1.text = ""
            blueVw.isHidden = true
        }
        
        // ✅ Force layout update
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // ✅ Calculate text width with max width limit
    private func calculateTextWidth(for text: String, font: UIFont, maxWidth: CGFloat? = nil) -> CGFloat {
        let constraintRect = CGSize(
            width: maxWidth ?? CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
        
        let boundingBox = text.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        
        return ceil(boundingBox.width)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        strikeThroughLine?.removeFromSuperview()
        strikeThroughLine = nil
        
        // ✅ Reset variant2 and blueVw2 on reuse
        variant2.text = ""
        blueVw2.isHidden = true
    }
}
