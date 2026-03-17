//
//  PracticeGameController.swift
//  FamilyFirst
//
//  Created by Lifeboat on 22/10/25.
//

import UIKit
import AVFoundation
import Lottie

class PracticeGameController: UIViewController {
    
    // MARK: - Audio & Timer Properties
    var player: AVPlayer?
    var playerObserver: Any?
    var timer: Timer?
    var remainingSeconds: Int = 60
    var isTimeOutSubmission: Bool = false
    
    // MARK: - IBOutlets
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblWordsCount: UILabel!
    @IBOutlet weak var nextWord: UIButton!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var congratsLbl: UILabel!
    @IBOutlet weak var bottomlbl: UILabel!
    @IBOutlet weak var SkipBtn: UIButton!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var topLbl: UILabel!
    @IBOutlet weak var lblActualSpelling: UILabel!
    @IBOutlet weak var lblEnteredSpelling: UILabel!
    @IBOutlet weak var viewLottie: LottieAnimationView!
    
    // MARK: - Word Properties
    var word_info: WordInfo?
    var wordsCompleted: Int = 0
    var selectedGradeId: String = ""
    var selectedGradeName: String = ""
    
    var hasWord: Bool {
        return word_info != nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getWords()
    }
    
    // MARK: - Setup
    
    func setupUI() {
        nextWord.tintColor = UIColor(red: 254/255, green: 242/255, blue: 0/255, alpha: 1.0)
        
        let gradeName = selectedGradeName.isEmpty ? "Practice" : selectedGradeName
        lblTitle.text = "Practice | \(gradeName)"
        
        resultView.isHidden = true
        lblEnteredSpelling.isHidden = true
        updateWordsCount()
    }
    
    func updateWordsCount() {
        lblWordsCount.text = "Words: \(wordsCompleted)"
    }
    
    // MARK: - Actions
    
    @IBAction func onClickBack(_ sender: UIButton) {
        stopTimer()
        view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickSubmit(_ sender: UIButton) {
        txtField.resignFirstResponder()
        
        guard hasWord else {
            showAlert(msg: "No word available")
            return
        }
        isTimeOutSubmission = false
        submitWord()
    }
    
    @IBAction func onClickSkip(_ sender: UIButton) {
        guard let word = word_info else { return }
        
        txtField.resignFirstResponder()
        stopTimer()
        submitSkippedWord()
        
        resultView.isHidden = false
        viewLottie.stop()
        viewLottie.isHidden = true
        
        congratsLbl.text = "Word Skipped!"
        congratsLbl.isHidden = false
        
        topLbl.text = "You skipped this word"
        topLbl.textAlignment = .center
        topLbl.isHidden = false
        
        bottomlbl.isHidden = true
        
        lblEnteredSpelling.text = "The correct spelling is:"
        lblEnteredSpelling.font = UIFont(name: "Lexend-Medium", size: 16)
        lblEnteredSpelling.textColor = .black
        lblEnteredSpelling.textAlignment = .center
        lblEnteredSpelling.isHidden = false
        
        let userFont = txtField.font ?? UIFont.systemFont(ofSize: 24)
        let correctWordAttr = NSAttributedString(
            string: word.word.uppercased(),
            attributes: [
                .font: userFont,
                .foregroundColor: UIColor.black
            ]
        )
        
        lblActualSpelling.attributedText = correctWordAttr
        lblActualSpelling.textAlignment = .center
        lblActualSpelling.isHidden = false
        lblActualSpelling.font = UIFont.boldSystemFont(ofSize: 24)
        
        txtField.text = ""
    }
    
    @IBAction func onClickNextWord(_ sender: UIButton) {
        stopTimer()
        resetResultView()
        getWords(playAudio: true)
    }
    
    @IBAction func onTapListen(_ sender: UIButton) {
        guard hasWord else {
            showAlert(msg: "No word available")
            return
        }
        guard let word = word_info else { return }
        playWordAudio(url: word.pronunciation)
    }
    
    @IBAction func onClickDefination(_ sender: UITapGestureRecognizer) {
        guard let word = word_info else { return }
        playWordAudio(url: word.definitionVoice)
    }
    
    @IBAction func onClickOrigin(_ sender: UITapGestureRecognizer) {
        guard let word = word_info else { return }
        playWordAudio(url: word.originVoice)
    }
    
    @IBAction func onClickUsage(_ sender: UITapGestureRecognizer) {
        guard let word = word_info else { return }
        playWordAudio(url: word.usageVoice)
    }
    
    @IBAction func onClickOther(_ sender: UITapGestureRecognizer) {
        guard let word = word_info else { return }
        if let ov = word.othersVoice {
            playWordAudio(url: ov)
        }
    }
    
    @IBAction func onClickExit(_ sender: UIButton) {
        stopTimer()
        view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onDefinitionClick(_ sender: UIButton) {
        guard let word = word_info else { return }
        playWordAudio(url: word.definitionVoice)
    }
    
    @IBAction func onUsageCLick(_ sender: UIButton) {
        guard let word = word_info else { return }
        playWordAudio(url: word.usageVoice)
    }
    
    @IBAction func onOriginClick(_ sender: UIButton) {
        guard let word = word_info else { return }
        playWordAudio(url: word.originVoice)
    }
    
    @IBAction func onOthersClick(_ sender: UIButton) {
        guard let word = word_info else { return }
        if let ov = word.othersVoice {
            playWordAudio(url: ov)
        }
    }
    
    // MARK: - Reset View
    
    func resetResultView() {
        resultView.isHidden = true
        lblEnteredSpelling.isHidden = true
        lblActualSpelling.isHidden = true
        bottomlbl.isHidden = true
        topLbl.isHidden = true
        congratsLbl.isHidden = true
        txtField.text = ""
        viewLottie.stop()
        viewLottie.isHidden = true
    }
    
    // MARK: - API Calls
    
    func getWords(playAudio: Bool = true) {
        showLoader()
        
        let url = "\(API.BASE_URL)vocabee/get/word?grade=\(selectedGradeId)"
        let shouldPlayAudio = playAudio
        
        NetworkManager.shared.request(
            urlString: url,
            method: .GET
        ) { [weak self] (result: Result<APIResponse<WordInfo>, NetworkError>) in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.hideLoader()
                
                switch result {
                case .success(let info):
                    if info.success, let data = info.data {
                        self.word_info = data
                        self.resetResultView()
                        
                        if shouldPlayAudio {
                            self.setupPlayer()
                        } else {
                            self.startTimer()
                        }
                    } else {
                        self.showNoMoreWordsAlert()
                    }
                    
                case .failure(let error):
                    switch error {
                    case .noaccess:
                        self.performLogout()
                    default:
                        self.showAlert(msg: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func submitWord() {
        guard let word = word_info else {
            print("⚠️ No word available to submit")
            return
        }
        
        txtField.resignFirstResponder()
        showLoader()
        
        let enteredText = txtField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() ?? ""
        
        let payload: [String: Any] = [
            "user_answer": enteredText,
            "word_id": word.id,
            "grade_id": selectedGradeId
        ]
        
        let url = "\(API.BASE_URL)vocabee/word"
        
        NetworkManager.shared.request(
            urlString: url,
            method: .POST,
            parameters: payload
        ) { [weak self] (result: Result<APIResponse<VocabBeeWordResponse>, NetworkError>) in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.hideLoader()
                self.stopTimer()
                
                switch result {
                case .success(let info):
                    guard info.success, let data = info.data else {
                        self.showAlert(msg: info.description ?? "Something went wrong")
                        return
                    }
                    
                    self.resultView.isHidden = false
                    
                    if data.isCorrect {
                        self.handleCorrectAnswer(data: data)
                    } else {
                        self.handleWrongAnswer(data: data)
                    }
                    
                case .failure(let error):
                    switch error {
                    case .noaccess:
                        self.performLogout()
                    default:
                        self.showAlert(msg: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func submitSkippedWord() {
        guard let word = word_info else { return }
        
        let payload: [String: Any] = [
            "user_answer": "",
            "word_id": word.id,
            "grade_id": selectedGradeId
        ]
        
        let url = "\(API.BASE_URL)vocabee/word"
        
        NetworkManager.shared.request(
            urlString: url,
            method: .POST,
            parameters: payload
        ) { (result: Result<APIResponse<VocabBeeWordResponse>, NetworkError>) in
            switch result {
            case .success(let info):
                print("Skip submitted: \(info.success)")
            case .failure(let error):
                print("Skip submit error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Handle Answers
    
    func handleCorrectAnswer(data: VocabBeeWordResponse) {
        wordsCompleted += 1
        updateWordsCount()
        
        bottomlbl.isHidden = true
        topLbl.isHidden = true
        congratsLbl.isHidden = false
        
        playSuccessLottie()
        
        congratsLbl.text = "Congratulations! Try new word"
        
        lblEnteredSpelling.text = "You've got it right!"
        lblEnteredSpelling.font = txtField.font
        lblEnteredSpelling.textColor = .black
        lblEnteredSpelling.textAlignment = .center
        lblEnteredSpelling.numberOfLines = 0
        lblEnteredSpelling.isHidden = false
        
        let userFont = txtField.font ?? UIFont.systemFont(ofSize: 24)
        let correctAttr = NSAttributedString(
            string: data.correctAnswer.uppercased(),
            attributes: [
                .font: userFont,
                .foregroundColor: UIColor.black
            ]
        )
        
        lblActualSpelling.attributedText = correctAttr
        lblActualSpelling.textAlignment = .center
        lblActualSpelling.isHidden = false
        lblActualSpelling.font = UIFont.boldSystemFont(ofSize: 24)
    }
    
    func handleWrongAnswer(data: VocabBeeWordResponse) {
        viewLottie.stop()
        viewLottie.isHidden = true
        
        let wrongText = txtField.text ?? ""
        
        if isTimeOutSubmission {
            congratsLbl.text = "Time's up! ⏰"
            topLbl.text = "You ran out of time"
        } else {
            congratsLbl.text = "That's Okay! Try the next word!"
            topLbl.text = "Oops! You got it wrong"
        }
        
        topLbl.textAlignment = .center
        topLbl.isHidden = false
        congratsLbl.isHidden = false
        
        let wrongAttr = NSAttributedString(
            string: wrongText.uppercased(),
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.systemRed,
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .strikethroughColor: UIColor.systemRed
            ]
        )
        
        bottomlbl.attributedText = wrongAttr
        bottomlbl.textAlignment = .center
        bottomlbl.numberOfLines = 0
        bottomlbl.isHidden = false
        
        lblEnteredSpelling.text = "Correct Spelling is as follows!"
        lblEnteredSpelling.font = UIFont(name: "Lexend-Medium", size: 16)
        lblEnteredSpelling.textColor = .black
        lblEnteredSpelling.textAlignment = .center
        lblEnteredSpelling.isHidden = false
        
        let userFont = txtField.font ?? UIFont.systemFont(ofSize: 24)
        let correctWordAttr = NSAttributedString(
            string: data.correctAnswer.uppercased(),
            attributes: [
                .font: userFont,
                .foregroundColor: UIColor.black
            ]
        )
        
        lblActualSpelling.attributedText = correctWordAttr
        lblActualSpelling.textAlignment = .center
        lblActualSpelling.isHidden = false
        lblActualSpelling.font = UIFont.boldSystemFont(ofSize: 24)
    }
    
    // MARK: - Audio Player
    
    func setupPlayer() {
        guard let word = word_info else {
            print("⚠️ No word available for player")
            return
        }
        
        startTimer()
        playWordAudio(url: word.pronunciation)
    }
    
    func playWordAudio(url: String) {
        guard let audioURL = URL(string: url) else {
            print("❌ Invalid audio URL")
            return
        }
        
        if let observer = playerObserver {
            NotificationCenter.default.removeObserver(observer)
            playerObserver = nil
        }
        
        let playerItem = AVPlayerItem(url: audioURL)
        player = AVPlayer(playerItem: playerItem)
        
        playerObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            print("✅ Audio finished playing")
        }
        
        player?.play()
        print("🔊 Playing audio...")
    }
    
    // MARK: - Timer
    
    func startTimer() {
        stopTimer()
        remainingSeconds = 60
        timerLbl.text = "\(remainingSeconds) Seconds Left..."
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
            guard let self = self else { return }
            
            self.remainingSeconds -= 1
            self.timerLbl.text = "\(self.remainingSeconds) Seconds Left..."
            
            if self.remainingSeconds <= 0 {
                t.invalidate()
                self.timer = nil
                self.autoSubmitEmptyAnswer()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func autoSubmitEmptyAnswer() {
        txtField.resignFirstResponder()
        isTimeOutSubmission = true
        txtField.text = ""
        submitWord()
    }
    
    // MARK: - Lottie Animations
    
    func playSuccessLottie() {
        viewLottie.animation = LottieAnimation.named("vocabbee_success")
        viewLottie.loopMode = .playOnce
        viewLottie.isHidden = false
        viewLottie.play()
    }
    
    func playWrongLottie() {
        viewLottie.animation = LottieAnimation.named("vocabbee_wrong")
        viewLottie.loopMode = .playOnce
        viewLottie.isHidden = false
        viewLottie.play()
    }
    
    // MARK: - Alerts
    
    func showNoMoreWordsAlert() {
        let alert = UIAlertController(
            title: "Practice Complete! 🎉",
            message: "You've practiced \(wordsCompleted) words. Great job!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    // MARK: - Logout
    
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
    
    // MARK: - Deinit
    
    deinit {
        if let observer = playerObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        player?.pause()
        player = nil
    }
}
