//
//  StartTestVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 08/11/25.
//

import UIKit

class StartTestVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSubjectName: UILabel!
    @IBOutlet weak var lblQuestions: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    
    var assessment: Assessment?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        guard let assessment = assessment else {
            showAlert(msg: "Assessment data not found. Please try again.")
            navigationController?.popViewController(animated: true)
            return
        }
        
        lblName.text = assessment.name
        lblSubjectName.text = assessment.subjectName
        lblDescription.text = "It's a focused test designed to help students practice selected topics, making it easier to understand concepts and apply them with confidence."
        lblQuestions.text = "\(assessment.numberOfQuestions) Questions | \(assessment.totalMarks) Marks"
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func onClickStartButton(_ sender: UIButton) {
        guard let assessment = assessment else {
            showAlert(msg: "Assessment data not found.")
            return
        }
        
        guard let vc = storyboard?.instantiateViewController(identifier: "QuestionVC") as? QuestionVC else {
            return
        }
        
        vc.assessment = assessment
        navigationController?.pushViewController(vc, animated: true)
    }
}
