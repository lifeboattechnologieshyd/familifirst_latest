//
//  QuestionVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 08/11/25.
//

import UIKit
import Lottie

class QuestionVC: UIViewController {
    
    @IBOutlet weak var lottieViewImage: LottieAnimationView!
    @IBOutlet weak var resultPopup: UIView!
    @IBOutlet weak var scoreVw: UIView!
    @IBOutlet weak var scoreNumberLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var viewanswersButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lblQuestionNumber: UILabel!
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var lblDesciption: UILabel!
    @IBOutlet weak var hintVw: UIView!
    @IBOutlet weak var hintLbl: UILabel!
    @IBOutlet weak var stackViewOptions: UIStackView!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var optionAView: UIView!
    @IBOutlet weak var lblTitleA: UILabel!
    @IBOutlet weak var lblOptionA: UILabel!
    @IBOutlet weak var optionBView: UIView!
    @IBOutlet weak var lblTitleB: UILabel!
    @IBOutlet weak var lblOptionB: UILabel!
    @IBOutlet weak var optionCView: UIView!
    @IBOutlet weak var lblTitleC: UILabel!
    @IBOutlet weak var lblOptionC: UILabel!
    @IBOutlet weak var optionDView: UIView!
    @IBOutlet weak var lblTitleD: UILabel!
    @IBOutlet weak var lblOptionD: UILabel!
    @IBOutlet weak var optionHintView: UIView!
    @IBOutlet weak var lblTitleHint: UILabel!
    @IBOutlet weak var lblOptionHint: UILabel!
    @IBOutlet weak var lblMarks: UILabel!
    @IBOutlet weak var lblPercentage: UILabel!
    @IBOutlet weak var lblSkipAns: UILabel!
    @IBOutlet weak var lblwrongAns: UILabel!
    @IBOutlet weak var lblCorrectAns: UILabel!
    @IBOutlet weak var lblTotalMarks: UILabel!
    
    var assessment: Assessment?
    var current_question = 0
    var darkOverlayView: UIView!
    let slashLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupHintView()
        setupQuestionsView()
    }
    
    private func setupUI() {
        guard assessment != nil else {
            showAlert(msg: "Assessment data not found")
            navigationController?.popViewController(animated: true)
            return
        }
        
        lblOptionA.text = ""
        lblOptionB.text = ""
        lblOptionC.text = ""
        lblOptionD.text = ""
        lblOptionHint.text = ""
        lblDesciption.text = ""
        stackViewOptions.isHidden = true
        resultPopup.isHidden = true
    }
    
    func setupHintView() {
        hintVw.isHidden = true
        hintVw.layer.masksToBounds = true
        
        darkOverlayView = UIView(frame: view.bounds)
        darkOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        darkOverlayView.isHidden = true
        darkOverlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        darkOverlayView.addGestureRecognizer(tapGesture)
        
        view.addSubview(darkOverlayView)
        view.bringSubviewToFront(hintVw)
        
        okBtn.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
    }
    
    func setupQuestionsView() {
        bgView.layer.cornerRadius = 16
        
        lblTitleA.text = "A"
        lblTitleB.text = "B"
        lblTitleC.text = "C"
        lblTitleD.text = "D"
        lblTitleHint.text = "E"
        
        lblTitleA.layer.cornerRadius = lblTitleA.frame.size.width / 2
        lblTitleB.layer.cornerRadius = lblTitleB.frame.size.width / 2
        lblTitleC.layer.cornerRadius = lblTitleC.frame.size.width / 2
        lblTitleD.layer.cornerRadius = lblTitleD.frame.size.width / 2
        lblTitleHint.layer.cornerRadius = lblTitleHint.frame.size.width / 2
        
        lblTitleA.layer.masksToBounds = true
        lblTitleB.layer.masksToBounds = true
        lblTitleC.layer.masksToBounds = true
        lblTitleD.layer.masksToBounds = true
        lblTitleHint.layer.masksToBounds = true
        
        for (index, view) in stackViewOptions.arrangedSubviews.enumerated() {
            view.tag = index
            view.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(optionTapped(_:)))
            view.addGestureRecognizer(tap)
        }
        
        changeQuestion()
    }
    
    @objc func okButtonTapped() {
        hideHintView()
    }
    
    @objc func overlayTapped() {
        hideHintView()
    }
    
    func showHintView() {
        guard let assessment = assessment,
              current_question < assessment.questions.count else { return }
        
        hintLbl.text = assessment.questions[current_question].hint
        
        darkOverlayView.isHidden = false
        darkOverlayView.alpha = 0
        hintVw.isHidden = false
        
        view.bringSubviewToFront(darkOverlayView)
        view.bringSubviewToFront(hintVw)
        
        okBtn.isUserInteractionEnabled = true
        hintVw.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.3) {
            self.darkOverlayView.alpha = 0.5
        }
    }
    
    func hideHintView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.darkOverlayView.alpha = 0
        }) { completed in
            if completed {
                self.darkOverlayView.isHidden = true
                self.hintVw.isHidden = true
            }
        }
    }
    
    @IBAction func onClickOkBtn(_ sender: UIButton) {
        okBtn.titleLabel?.font = UIFont.lexend(.semiBold, size: 16)
        hideHintView()
    }
    
    func changeQuestion() {
        guard let assessment = assessment,
              current_question < assessment.questions.count else { return }
        
        hintVw.isHidden = true
        darkOverlayView.isHidden = true
        
        let question = assessment.questions[current_question]
        
        lblQuestionNumber.text = "Question \(current_question + 1)/\(assessment.numberOfQuestions)"
        lblQuestion.animateTyping(text: question.question) {
            self.lblDesciption.animateTyping(text: question.description) {
                if question.options.count >= 4 {
                    self.lblOptionA.text = question.options[0]
                    self.lblOptionB.text = question.options[1]
                    self.lblOptionC.text = question.options[2]
                    self.lblOptionD.text = question.options[3]
                }
                self.lblOptionHint.text = "I don't know"
                self.stackViewOptions.isHidden = false
            }
        }
    }
    
    @objc func optionTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view,
              let assessment = assessment,
              current_question < assessment.questions.count else { return }
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        UIView.animate(withDuration: 0.1,
                       animations: {
            view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        },
                       completion: { _ in
            UIView.animate(withDuration: 0.1) {
                view.transform = .identity
            }
        })
        
        if view.tag == 4 {
            showHintView()
            return
        }
        
        let selected_ans = String(view.tag)
        attemptAns(ans: selected_ans, index: view.tag)
        
        for v in stackViewOptions.arrangedSubviews {
            v.isUserInteractionEnabled = false
        }
    }
    
    func highlightSelection(at index: Int) {
        guard let assessment = assessment,
              current_question < assessment.questions.count else { return }
        
        let ans = assessment.questions[current_question].answer
        
        switch index {
        case 0:
            optionAView.backgroundColor = ans == lblOptionA.text ? UIColor(hex: "00BB00") : UIColor(hex: "#FFA700")
        case 1:
            optionBView.backgroundColor = ans == lblOptionB.text ? UIColor(hex: "00BB00") : UIColor(hex: "#FFA700")
        case 2:
            optionCView.backgroundColor = ans == lblOptionC.text ? UIColor(hex: "00BB00") : UIColor(hex: "#FFA700")
        case 3:
            optionDView.backgroundColor = ans == lblOptionD.text ? UIColor(hex: "00BB00") : UIColor(hex: "#FFA700")
        case 4:
            optionHintView.backgroundColor = UIColor(hex: "#FFA700")
        default:
            break
        }
        
        if ans == lblOptionA.text {
            optionAView.backgroundColor = UIColor(hex: "00BB00")
        } else if ans == lblOptionB.text {
            optionBView.backgroundColor = UIColor(hex: "00BB00")
        } else if ans == lblOptionC.text {
            optionCView.backgroundColor = UIColor(hex: "00BB00")
        } else if ans == lblOptionD.text {
            optionDView.backgroundColor = UIColor(hex: "00BB00")
        }
        
        if assessment.numberOfQuestions > current_question + 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.resetOptionsAndMoveToNextQuestion()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.getStats()
            }
        }
    }
    
    func resetOptionsAndMoveToNextQuestion() {
        for v in stackViewOptions.arrangedSubviews {
            v.backgroundColor = .systemBackground
            v.isUserInteractionEnabled = true
            v.layer.borderColor = UIColor.systemBlue.cgColor
        }
        
        lblDesciption.text = ""
        stackViewOptions.isHidden = true
        
        lblTitleA.backgroundColor = .systemBlue
        lblTitleA.textColor = .white
        lblOptionA.textColor = .black
        
        lblTitleB.backgroundColor = .systemBlue
        lblTitleB.textColor = .white
        lblOptionB.textColor = .black
        
        lblTitleC.backgroundColor = .systemBlue
        lblTitleC.textColor = .white
        lblOptionC.textColor = .black
        
        lblTitleD.backgroundColor = .systemBlue
        lblTitleD.textColor = .white
        lblOptionD.textColor = .black
        
        lblTitleHint.backgroundColor = .systemBlue
        lblTitleHint.textColor = .white
        lblOptionHint.textColor = .black
        
        hintVw.isHidden = true
        darkOverlayView.isHidden = true
        
        current_question += 1
        changeQuestion()
    }
    
    func displayResultPopup() {
        bgView.isHidden = true
        resultPopup.isHidden = false
        viewanswersButton.titleLabel?.font = UIFont.lexend(.semiBold, size: 20)
    }
    
    @IBAction func onClickHome() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func onClickPlayMore() {
        guard let vc = storyboard?.instantiateViewController(identifier: "AssessmentsGradeSelectionVC") as? AssessmentsGradeSelectionVC else { return }
        navigationController?.popToViewController(vc, animated: true)
    }
    
    @IBAction func onClickAnswers(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "AllQuestionsVC") as? AllQuestionsVC,
              let assessment = assessment else { return }
        vc.assessmentId = assessment.id
        vc.is_back_to_root = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func getStats() {
        guard let assessment = assessment else {
            showAlert(msg: "Assessment data not found")
            return
        }
        
        // ✅ CHANGED: Using GET method with query parameter instead of POST with payload
        let url = "\(API.EDUTAIN_MY_RESULTS)?assessment_id=\(assessment.id)"
        
        NetworkManager.shared.request(urlString: url, method: .GET) { (result: Result<APIResponse<AssessmentAnswerResponse>, NetworkError>) in
            switch result {
            case .success(let info):
                if info.success, let data = info.data {
                    DispatchQueue.main.async {
                        self.displayResultPopup()
                        self.slider.value = Float(data.totalMarks)
                        self.slider.maximumValue = Float(assessment.totalMarks)
                        let percentage = assessment.totalMarks > 0 ? Int(Float(data.totalMarks) / Float(assessment.totalMarks) * 100) : 0
                        self.lblPercentage.text = "\(percentage) %"
                        self.slider.minimumValue = 0
                        self.lblMarks.text = "\(data.totalMarks)"
                        self.lblTotalMarks.text = "\(assessment.totalMarks)"
                        self.lblwrongAns.text = "\(data.wrongQuestions)"
                        self.lblCorrectAns.text = "\(data.correctQuestions)"
                        self.lblSkipAns.text = "\(data.skippedQuestions)"
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(msg: info.description)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    switch error {
                    case .noaccess:
                        self.performLogout()
                    default:
                        self.showAlert(msg: error.localizedDescription)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    func attemptAns(ans: String, index: Int) {
        guard let assessment = assessment,
              current_question < assessment.questions.count else { return }
        
        let payload: [String: Any] = [
            "question_id": assessment.questions[current_question].id,
            "assessment_id": assessment.id,
            "answer": ans
        ]
        
        NetworkManager.shared.request(urlString: API.EDUTAIN_ASSESSMENT_ATTEMPT, method: .POST, parameters: payload) { (result: Result<APIResponse<AssessmentAnswerResponse>, NetworkError>) in
            switch result {
            case .success(let info):
                if info.success {
                    DispatchQueue.main.async {
                        self.highlightSelection(at: index)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(msg: info.description)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    switch error {
                    case .noaccess:
                        self.performLogout()
                    default:
                        self.showAlert(msg: error.localizedDescription)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    func performLogout() {
        UserManager.shared.logout()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
            let navController = UINavigationController(rootViewController: loginVC)
            navController.modalPresentationStyle = .fullScreen
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = navController
                window.makeKeyAndVisible()
            }
        }
    }
}
