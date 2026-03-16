//
//  MonthHeaderView.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 07/03/26.
//

import UIKit

class MonthHeaderView: UIView {
    
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    var currentDate = Date() {
        didSet {
            updateMonthLabel()
        }
    }
    
    var onDateChanged: ((Date) -> Void)?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        guard subviews.isEmpty else { return }
        
        let nib = UINib(nibName: "MonthHeaderView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        
        updateMonthLabel()
    }
    
    // MARK: - Update UI
    
    private func updateMonthLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        lblMonth?.text = formatter.string(from: currentDate)
    }
    
    // MARK: - Actions
    
    @IBAction func onClickPrevious(_ sender: UIButton) {
        guard let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) else { return }
        currentDate = newDate
        onDateChanged?(currentDate)
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        guard let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) else { return }
        currentDate = newDate
        onDateChanged?(currentDate)
    }
}
