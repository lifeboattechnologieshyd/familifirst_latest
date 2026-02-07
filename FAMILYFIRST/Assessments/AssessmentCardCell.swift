//
//  AssessmentCardCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 24/11/25.
//

import UIKit

class AssessmentCardCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblScore: UILabel!
    @IBOutlet weak var btnSeeAns: UIButton!
    @IBOutlet weak var imgStudent: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    var onSelectAns: ((Int) -> Void)!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setup(assessment: AssessmentSummary) {
        self.lblTitle.text = assessment.assessmentName
        self.lblDescription.text = assessment.description
        self.lblScore.text = "You've scored \(assessment.studentMarks)/\(assessment.totalMarks)"
        
        let progress = Float(assessment.studentMarks) / Float(assessment.totalMarks)
        progressView.setProgress(progress, animated: false)
    }
    
    func setupEdutain(assessment: EdutainResultData) {
        self.lblTitle.text = assessment.assessment_name
        self.lblDescription.text = "\(assessment.attempted_questions)/\(assessment.number_of_questions) Questions Attempted"
        self.lblScore.text = "You've scored \(assessment.total_marks) Marks"
        
        let progress = assessment.number_of_questions > 0 ? Float(assessment.attempted_questions) / Float(assessment.number_of_questions) : 0
        progressView.setProgress(progress, animated: false)
    }
    
    @IBAction func onClickSeeAnswers(_ sender: UIButton) {
        onSelectAns(sender.tag)
    }
}
