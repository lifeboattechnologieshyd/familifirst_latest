//
//  QuestionVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 08/11/25.
//

import UIKit
import Lottie
import AVFoundation

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
    @IBOutlet weak var questionscoreLbl: UILabel!
    @IBOutlet weak var lblDesciption: UILabel!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var playBtn: UIButton!
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
    let startCircleLayer = CAShapeLayer()
    let endCircleLayer = CAShapeLayer()
    let speechSynthesizer = AVSpeechSynthesizer()
    var celebrationLottieView: LottieAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupHintView()
        setupQuestionsView()
        setupCelebrationLottie()
        scoreVw.layer.borderWidth = 0
        scoreVw.layer.borderColor = UIColor.clear.cgColor
        scoreVw.layer.cornerRadius = 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        drawSlash()
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
        lottieViewImage.isHidden = true
        questionscoreLbl.text = ""
    }
    
    func setupCelebrationLottie() {
        celebrationLottieView = LottieAnimationView()
        celebrationLottieView.animation = LottieAnimation.named("Celebration")
        celebrationLottieView.contentMode = .scaleAspectFit
        celebrationLottieView.loopMode = .playOnce
        celebrationLottieView.animationSpeed = 1.0
        celebrationLottieView.backgroundColor = .clear
        celebrationLottieView.isHidden = true
        celebrationLottieView.isUserInteractionEnabled = false
        
        view.addSubview(celebrationLottieView)
        
        celebrationLottieView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            celebrationLottieView.topAnchor.constraint(equalTo: view.topAnchor),
            celebrationLottieView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            celebrationLottieView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            celebrationLottieView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func playCorrectAnswerLottie() {
        guard celebrationLottieView != nil else { return }
        guard celebrationLottieView.animation != nil else { return }
        
        view.bringSubviewToFront(celebrationLottieView)
        celebrationLottieView.isHidden = false
        celebrationLottieView.currentProgress = 0
        
        celebrationLottieView.play { [weak self] completed in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.celebrationLottieView.stop()
                self.celebrationLottieView.isHidden = true
                self.celebrationLottieView.currentProgress = 0
            }
        }
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
        
        lblTitleA.backgroundColor = .primary
        lblTitleA.textColor = .secondary
        
        lblTitleB.backgroundColor = .primary
        lblTitleB.textColor = .secondary
        
        lblTitleC.backgroundColor = .primary
        lblTitleC.textColor = .secondary
        
        lblTitleD.backgroundColor = .primary
        lblTitleD.textColor = .secondary
        
        lblTitleHint.backgroundColor = .primary
        lblTitleHint.textColor = .secondary
        
        optionAView.layer.borderColor = UIColor.primary.cgColor
        optionAView.layer.borderWidth = 1
        
        optionBView.layer.borderColor = UIColor.primary.cgColor
        optionBView.layer.borderWidth = 1
        
        optionCView.layer.borderColor = UIColor.primary.cgColor
        optionCView.layer.borderWidth = 1
        
        optionDView.layer.borderColor = UIColor.primary.cgColor
        optionDView.layer.borderWidth = 1
        
        optionHintView.layer.borderColor = UIColor.primary.cgColor
        optionHintView.layer.borderWidth = 1
        
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
    
    @IBAction func onClickPlayBtn(_ sender: UIButton) {
        guard let assessment = assessment,
              current_question < assessment.questions.count else { return }
        
        let questionText = assessment.questions[current_question].question
        let descriptionText = assessment.questions[current_question].description
        let fullText = "\(questionText). \(descriptionText)"
        
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: fullText)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        
        speechSynthesizer.speak(utterance)
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
        
        questionscoreLbl.text = "\(question.marks)"
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
        
        UIView.animate(withDuration: 0.1, animations: {
            view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                view.transform = .identity
            }
        })
        
        if view.tag == 4 {
            showHintView()
            return
        }
        
        let selected_ans = assessment.questions[current_question].options[view.tag]
        attemptAns(ans: selected_ans, index: view.tag)
        
        for v in stackViewOptions.arrangedSubviews {
            v.isUserInteractionEnabled = false
        }
    }
    
    func highlightSelection(at index: Int) {
        guard let assessment = assessment,
              current_question < assessment.questions.count else { return }
        
        let ans = assessment.questions[current_question].answer
        var isCorrectAnswer = false
        
        switch index {
        case 0:
            isCorrectAnswer = (ans == lblOptionA.text)
            optionAView.backgroundColor = isCorrectAnswer ? UIColor(hex: "00BB00") : UIColor(hex: "#FFA700")
        case 1:
            isCorrectAnswer = (ans == lblOptionB.text)
            optionBView.backgroundColor = isCorrectAnswer ? UIColor(hex: "00BB00") : UIColor(hex: "#FFA700")
        case 2:
            isCorrectAnswer = (ans == lblOptionC.text)
            optionCView.backgroundColor = isCorrectAnswer ? UIColor(hex: "00BB00") : UIColor(hex: "#FFA700")
        case 3:
            isCorrectAnswer = (ans == lblOptionD.text)
            optionDView.backgroundColor = isCorrectAnswer ? UIColor(hex: "00BB00") : UIColor(hex: "#FFA700")
        case 4:
            optionHintView.backgroundColor = UIColor(hex: "#FFA700")
        default:
            break
        }
        
        if isCorrectAnswer {
            playCorrectAnswerLottie()
        }
        
        if !isCorrectAnswer {
            if ans == lblOptionA.text {
                optionAView.backgroundColor = UIColor(hex: "00BB00")
            } else if ans == lblOptionB.text {
                optionBView.backgroundColor = UIColor(hex: "00BB00")
            } else if ans == lblOptionC.text {
                optionCView.backgroundColor = UIColor(hex: "00BB00")
            } else if ans == lblOptionD.text {
                optionDView.backgroundColor = UIColor(hex: "00BB00")
            }
        }
        
        if assessment.numberOfQuestions > current_question + 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.resetOptionsAndMoveToNextQuestion()
            }
        } else {
            self.getStats()
        }
    }
    
    func resetOptionsAndMoveToNextQuestion() {
        for v in stackViewOptions.arrangedSubviews {
            v.backgroundColor = .systemBackground
            v.isUserInteractionEnabled = true
            v.layer.borderColor = UIColor.primary.cgColor
        }
        
        lblDesciption.text = ""
        stackViewOptions.isHidden = true
        
        lblTitleA.backgroundColor = .primary
        lblTitleA.textColor = .secondary
        lblOptionA.textColor = .black
        
        lblTitleB.backgroundColor = .primary
        lblTitleB.textColor = .secondary
        lblOptionB.textColor = .black
        
        lblTitleC.backgroundColor = .primary
        lblTitleC.textColor = .secondary
        lblOptionC.textColor = .black
        
        lblTitleD.backgroundColor = .primary
        lblTitleD.textColor = .secondary
        lblOptionD.textColor = .black
        
        lblTitleHint.backgroundColor = .primary
        lblTitleHint.textColor = .secondary
        lblOptionHint.textColor = .black
        
        optionAView.layer.borderColor = UIColor.primary.cgColor
        optionBView.layer.borderColor = UIColor.primary.cgColor
        optionCView.layer.borderColor = UIColor.primary.cgColor
        optionDView.layer.borderColor = UIColor.primary.cgColor
        optionHintView.layer.borderColor = UIColor.primary.cgColor
        
        hintVw.isHidden = true
        darkOverlayView.isHidden = true
        
        lottieViewImage.isHidden = true
        lottieViewImage.stop()
        
        celebrationLottieView?.stop()
        celebrationLottieView?.isHidden = true
        celebrationLottieView?.currentProgress = 0
        
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        current_question += 1
        changeQuestion()
    }
    
    @IBAction func onClickHome() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func onClickPlayMore() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        guard let navController = navigationController else { return }
        
        for controller in navController.viewControllers {
            if controller is AssessmentsGradeSelectionVC {
                navController.popToViewController(controller, animated: true)
                return
            }
        }
        
        if let vc = storyboard?.instantiateViewController(identifier: "AssessmentsGradeSelectionVC") as? AssessmentsGradeSelectionVC {
            navController.pushViewController(vc, animated: true)
        }
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
        
        showLoader()
        let url = "\(API.EDUTAIN_MY_RESULTS)?assessment_id=\(assessment.id)"
        
        NetworkManager.shared.request(urlString: url, method: .GET) { (result: Result<APIResponse<[EdutainResultData]>, NetworkError>) in
            self.hideLoader()
            switch result {
            case .success(let info):
                if let resultData = info.data?.first {
                    DispatchQueue.main.async {
                        self.bgView.isHidden = true
                        self.resultPopup.isHidden = false
                        self.topVw?.isHidden = true
                        
                        let userMarks = resultData.total_marks
                        let totalMarks = assessment.totalMarks
                        let attemptedQuestions = resultData.attempted_questions
                        let totalQuestions = resultData.number_of_questions
                        let skippedQuestions = totalQuestions - attemptedQuestions
                        let correctQuestions = attemptedQuestions
                        let wrongQuestions = 0
                        
                        self.slider.value = Float(userMarks)
                        self.slider.maximumValue = Float(totalMarks)
                        self.slider.minimumValue = 0
                        
                        let percentage = totalMarks > 0 ? Int(Float(userMarks) / Float(totalMarks) * 100) : 0
                        self.lblPercentage.text = "\(percentage)%"
                        
                        self.lblMarks.text = "\(userMarks)"
                        self.lblTotalMarks.text = "\(totalMarks)"
                        self.lblwrongAns.text = "\(wrongQuestions)"
                        self.lblCorrectAns.text = "\(correctQuestions)"
                        self.lblSkipAns.text = "\(skippedQuestions)"
                        
                        self.scoreNumberLbl?.text = "\(userMarks)"
                        self.totalLbl?.text = "/\(totalMarks)"
                                            
                        if self.speechSynthesizer.isSpeaking {
                            self.speechSynthesizer.stopSpeaking(at: .immediate)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(msg: "No results found. Please try again.")
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
        
        showLoader()
        let payload: [String: Any] = [
            "question_id": assessment.questions[current_question].id,
            "assessment_id": assessment.id,
            "answer": ans
        ]
        
        NetworkManager.shared.request(urlString: API.EDUTAIN_ASSESSMENT_ATTEMPT, method: .POST, parameters: payload) { (result: Result<APIResponse<AssessmentAnswerResponse>, NetworkError>) in
            self.hideLoader()
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
    
    func drawSlash() {
        slashLayer.removeFromSuperlayer()
        startCircleLayer.removeFromSuperlayer()
        
        let centerX = scoreVw.bounds.width / 2
        let centerY = scoreVw.bounds.height / 2
        let radius = min(scoreVw.bounds.width, scoreVw.bounds.height) / 2 - 4
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        startCircleLayer.path = circlePath.cgPath
        startCircleLayer.fillColor = UIColor.clear.cgColor
        startCircleLayer.strokeColor = UIColor.primary.cgColor
        startCircleLayer.lineWidth = 3
        scoreVw.layer.addSublayer(startCircleLayer)
        
        let slashPath = UIBezierPath()
        slashPath.move(to: CGPoint(x: centerX - radius * 0.5, y: centerY + radius * 0.5))
        slashPath.addLine(to: CGPoint(x: centerX + radius * 0.5, y: centerY - radius * 0.5))
        slashLayer.path = slashPath.cgPath
        slashLayer.strokeColor = UIColor.primary.cgColor
        slashLayer.lineWidth = 3
        slashLayer.fillColor = UIColor.clear.cgColor
        slashLayer.lineCap = .round
        scoreVw.layer.addSublayer(slashLayer)
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
