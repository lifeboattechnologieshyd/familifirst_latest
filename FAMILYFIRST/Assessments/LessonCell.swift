//
//  LessonCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 11/10/25.
//

import UIKit

class LessonCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var btnSelect: UIButton!
    
    var onSelectingLesson: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        btnSelect.addTarget(self, action: #selector(selectButtonTapped(_:)), for: .touchUpInside)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onSelectingLesson = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func selectButtonTapped(_ sender: UIButton) {
        onSelectingLesson?(sender.tag)
    }
    
    @IBAction func onClickSelectLesson(_ sender: UIButton) {
        onSelectingLesson?(sender.tag)
    }
}
