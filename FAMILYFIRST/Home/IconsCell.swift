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
    @IBOutlet weak var vocabbeBtn: UIButton!
    @IBOutlet weak var myfamiltBtn: UIButton!
    @IBOutlet weak var myeventsbtn: UIButton!
    @IBOutlet weak var edStoreBtn: UIButton!
    @IBOutlet weak var assessmentsBtn: UIButton!
    @IBOutlet weak var prosperitytipsBtn: UIButton!
    @IBOutlet weak var parentingTipsBtn: UIButton!
    
    var didTapCourses: (() -> Void)?
    var didTapFeels: (() -> Void)?
    var didTapEdutainment: (() -> Void)?
    var didTapVocabBee: (() -> Void)?
    var didTapProsperityTips: (() -> Void)?
    var didTapParentingTips: (() -> Void)?
    var didTapAssessments: (() -> Void)?
    var didTapMyFamily: (() -> Void)?
    var didTapMyEvents: (() -> Void)?
    var didTapEdStore: (() -> Void)?


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
        didTapParentingTips = nil
        didTapAssessments = nil
        didTapMyFamily = nil
        didTapMyEvents = nil
        didTapEdStore = nil
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
    
    @IBAction func parentingTipsBtnTapped(_ sender: UIButton) {
        didTapParentingTips?()
    }
    
    @IBAction func assessmentsBtnTapped(_ sender: UIButton) {
        didTapAssessments?()
    }
    
    @IBAction func myeventsbtnTapped(_ sender: UIButton) {
        didTapMyEvents?()
    }
    
    @IBAction func myfamiltBtnTapped(_ sender: UIButton) {
        didTapMyFamily?()
    }
    @IBAction func vocabbeeBtnTapped(_ sender: UIButton) {
        didTapVocabBee?()
    }

    @IBAction func edStoreBtnTapped(_ sender: UIButton) {
        didTapEdStore?()
    }
}
