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
        print("📱 StartTestVC loaded")
        print("📱 Assessment is nil: \(assessment == nil)")
        
        if let assessment = assessment {
            print("📱 Assessment ID: \(assessment.id)")
            print("📱 Number of questions: \(assessment.numberOfQuestions)")
            print("📱 Questions count: \(assessment.questions.count)")
        }
        
        setupUI()
    }
    
    private func setupUI() {
        guard let assessment = assessment else {
            print("❌ Assessment is nil in setupUI")
            showAlert(msg: "Assessment data not found. Please try again.")
            navigationController?.popViewController(animated: true)
            return
        }
        
        lblName.text = assessment.name
        lblSubjectName.text = assessment.description
        lblDescription.text = "It's a focused test designed to help students practice selected topics, making it easier to understand concepts and apply them with confidence."
        lblQuestions.text = "\(assessment.numberOfQuestions) Questions | \(assessment.totalMarks) Marks"
        
        print("✅ UI setup complete")
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func onClickStartButton(_ sender: UIButton) {
        print("📱 Start button clicked")
        
        guard let assessment = assessment else {
            print("❌ Assessment is nil when clicking start")
            showAlert(msg: "Assessment data not found.")
            return
        }
        
        print("📱 Assessment has \(assessment.questions.count) questions")
        
        guard let vc = storyboard?.instantiateViewController(identifier: "QuestionVC") as? QuestionVC else {
            print("❌ Failed to instantiate QuestionVC")
            return
        }
        
        print("✅ QuestionVC instantiated successfully")
        vc.assessment = assessment
        
        print("✅ Navigating to QuestionVC")
        navigationController?.pushViewController(vc, animated: true)
    }
}
