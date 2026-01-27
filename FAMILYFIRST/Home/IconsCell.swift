//
//  IconsCell.swift
//  FamilyFirst
//
//  Created by Lifeboat on 10/01/26.
//

import UIKit

class IconsCell: UITableViewCell {

    @IBOutlet weak var coursesBtn: UIButton!
    @IBOutlet weak var feelsBtn: UIButton!
    @IBOutlet weak var edutainmentBtn: UIButton!
    @IBOutlet weak var storeBtn: UIButton!
    @IBOutlet weak var assessmentsBtn: UIButton!
    @IBOutlet weak var prosperitytipsBtn: UIButton!
    @IBOutlet weak var offlineeventsBtn: UIButton!
    @IBOutlet weak var parentingTipsBtn: UIButton!
    
    var didTapCourses: (() -> Void)?
    var didTapFeels: (() -> Void)?
    var didTapEdutainment: (() -> Void)?
    var didTapVocabBee: (() -> Void)?
    var didTapProsperityTips: (() -> Void)?
    var didTapStore: (() -> Void)?
    var didTapOfflineEvents: (() -> Void)?
    var didTapParentingTips: (() -> Void)?
    var didTapAssessments: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        didTapCourses = nil
        didTapFeels = nil
        didTapEdutainment = nil
        didTapVocabBee = nil
        didTapProsperityTips = nil
        didTapStore = nil
        didTapOfflineEvents = nil
        didTapParentingTips = nil
        didTapAssessments = nil
    }

    @IBAction func coursesBtnTapped(_ sender: UIButton) {
        didTapCourses?()
    }

    @IBAction func feelsBtnTapped(_ sender: UIButton) {
        didTapFeels?()
    }

    @IBAction func edutainmentBtnTapped(_ sender: UIButton) {
        didTapEdutainment?()
    }

    @IBAction func prosperitytipsBtnTapped(_ sender: UIButton) {
        didTapProsperityTips?()
    }

    @IBAction func storeBtnTapped(_ sender: UIButton) {
        didTapStore?()
    }

    @IBAction func offlineEventsBtnTapped(_ sender: UIButton) {
        didTapOfflineEvents?()
    }
    
    @IBAction func parentingTipsBtnTapped(_ sender: UIButton) {
        didTapParentingTips?()
    }
    
    @IBAction func assessmentsBtnTapped(_ sender: UIButton) {
        didTapAssessments?()
    }
}
