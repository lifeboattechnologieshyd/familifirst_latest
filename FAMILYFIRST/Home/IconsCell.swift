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
    @IBOutlet weak var calenderBtn: UIButton!
    @IBOutlet weak var myeventsbtn: UIButton!
    @IBOutlet weak var famililiveLbl: UILabel!
    @IBOutlet weak var learnspaceLbl: UILabel!
    @IBOutlet weak var engageLbl: UILabel!
    @IBOutlet weak var edStoreBtn: UIButton!
    @IBOutlet weak var assessmentsBtn: UIButton!
    @IBOutlet weak var prosperitytipsBtn: UIButton!
    @IBOutlet weak var parentingTipsBtn: UIButton!
    
    // MARK: - Line Views for LearnSpace
    private let learnspaceLeftLine = UIView()
    private let learnspaceRightLine = UIView()
    
    // MARK: - Line Views for Engage
    private let engageLeftLine = UIView()
    private let engageRightLine = UIView()
    
    // MARK: - Line Views for FamiliLive
    private let familiveLeftLine = UIView()
    private let familiveRightLine = UIView()
    
    // MARK: - Closure Callbacks
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
    var didTapCalender: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupAllLineViews()
    }
    
    // MARK: - Setup All Line Views
    private func setupAllLineViews() {
        // Define the green color #076839
        let greenColor = UIColor(red: 7/255, green: 104/255, blue: 57/255, alpha: 1)
        
        // Setup lines for LearnSpace label
        setupLineViews(
            leftLine: learnspaceLeftLine,
            rightLine: learnspaceRightLine,
            forLabel: learnspaceLbl,
            color: greenColor
        )
        
        // Setup lines for Engage label
        setupLineViews(
            leftLine: engageLeftLine,
            rightLine: engageRightLine,
            forLabel: engageLbl,
            color: greenColor
        )
        
        // Setup lines for FamiliLive label
        setupLineViews(
            leftLine: familiveLeftLine,
            rightLine: familiveRightLine,
            forLabel: famililiveLbl,
            color: greenColor
        )
    }
    
    private func setupLineViews(leftLine: UIView, rightLine: UIView, forLabel label: UILabel, color: UIColor) {
        // Configure Left Line View
        leftLine.backgroundColor = color
        leftLine.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure Right Line View
        rightLine.backgroundColor = color
        rightLine.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to content view
        contentView.addSubview(leftLine)
        contentView.addSubview(rightLine)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Left Line View Constraints
            leftLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            leftLine.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -8),
            leftLine.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            leftLine.heightAnchor.constraint(equalToConstant: 1),
            
            // Right Line View Constraints
            rightLine.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
            rightLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            rightLine.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            rightLine.heightAnchor.constraint(equalToConstant: 1)
        ])
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
        didTapCalender = nil
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
    
    // ADD THIS ACTION
    @IBAction func calenderBtnTapped(_ sender: UIButton) {
        didTapCalender?()
    }
}
