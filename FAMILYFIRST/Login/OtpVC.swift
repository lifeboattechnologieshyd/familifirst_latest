//
//  OtpVC.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 28/01/26.
//
import UIKit
import Lottie

class OtpVC: UIViewController {

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var lottieVw: UIView!
    @IBOutlet weak var otpTf1: UITextField!
    @IBOutlet weak var otpTf2: UITextField!
    @IBOutlet weak var otpTf3: UITextField!
    @IBOutlet weak var otpTf4: UITextField!
    @IBOutlet weak var resendBtn: UIButton!
    @IBOutlet weak var verifyBtn: UIButton!
    
    var mobileNumber: String = ""
    private var resendTimer: Timer?
    private var resendSeconds = 30
    private var animationView: LottieAnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupOTPFields()
        startResendTimer()
        setupLottie()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animationView?.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resendTimer?.invalidate()
        animationView?.stop()
    }
    
    private func setupLottie() {
        animationView = LottieAnimationView(name: "otp")
        guard let animationView = animationView else { return }
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.0
        animationView.translatesAutoresizingMaskIntoConstraints = false
        lottieVw.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: lottieVw.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: lottieVw.bottomAnchor),
            animationView.leadingAnchor.constraint(equalTo: lottieVw.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: lottieVw.trailingAnchor)
        ])
        
        animationView.play()
    }
    
    private func setupUI() {
        otpTf1.becomeFirstResponder()
    }
    
    private func setupOTPFields() {
        let textFields = [otpTf1, otpTf2, otpTf3, otpTf4]
        
        textFields.forEach { tf in
            tf?.delegate = self
            tf?.keyboardType = .numberPad
            tf?.textAlignment = .center
            tf?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    
    private func startResendTimer() {
        resendSeconds = 30
        resendBtn.isEnabled = false
        updateResendButtonTitle()
        
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.resendSeconds -= 1
            self.updateResendButtonTitle()
            
            if self.resendSeconds <= 0 {
                self.resendTimer?.invalidate()
                self.resendBtn.isEnabled = true
                self.resendBtn.setTitle("Resend OTP", for: .normal)
            }
        }
    }
    
    private func updateResendButtonTitle() {
        resendBtn.setTitle("Resend in \(resendSeconds)s", for: .normal)
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func verifyBtnTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        let otp = getOTP()
        
        guard otp.count == 4 else {
            showAlert("Please enter complete OTP")
            return
        }
        
        verifyOTP(otp: otp)
    }
    
    @IBAction func resendBtnTapped(_ sender: UIButton) {
        resendOTP()
    }
    
    private func getOTP() -> String {
        let otp1 = otpTf1.text ?? ""
        let otp2 = otpTf2.text ?? ""
        let otp3 = otpTf3.text ?? ""
        let otp4 = otpTf4.text ?? ""
        return otp1 + otp2 + otp3 + otp4
    }
    
    private func clearOTP() {
        otpTf1.text = ""
        otpTf2.text = ""
        otpTf3.text = ""
        otpTf4.text = ""
        otpTf1.becomeFirstResponder()
    }
    
    private func verifyOTP(otp: String) {
        showLoading(true)
        
        let params: [String: Any] = [
            "mobile": mobileNumber,
            "otp": otp
        ]
        
        NetworkManager.shared.request(
            urlString: API.VERIFY_OTP,
            method: .POST,
            parameters: params
        ) { [weak self] (result: Result<APIResponse<VerifyOTPResponse>, NetworkError>) in
            
            DispatchQueue.main.async {
                self?.showLoading(false)
                
                switch result {
                case .success(let response):
                    if response.success {
                        if let data = response.data {
                            // Save tokens if available
                            if let access = data.accessToken, let refresh = data.refreshToken {
                                UserManager.shared.saveTokens(access: access, refresh: refresh)
                            }
                            
                            // Check if need to set password
                            if data.setNewPassword == true || data.isNewUser == true {
                                self?.goToSetPasswordVC()
                            } else {
                                // ✅ Login complete - dismiss
                                self?.dismissLoginFlow()
                            }
                        } else {
                            self?.goToSetPasswordVC()
                        }
                    } else {
                        self?.showAlert(response.description)
                        self?.clearOTP()
                    }
                    
                case .failure(let error):
                    self?.handleError(error)
                    self?.clearOTP()
                }
            }
        }
    }
    
    private func resendOTP() {
        resendBtn.isEnabled = false
        resendBtn.setTitle("Sending...", for: .normal)
        
        let params: [String: Any] = ["mobile": mobileNumber]
        
        NetworkManager.shared.request(
            urlString: API.RESEND_OTP,
            method: .POST,
            parameters: params
        ) { [weak self] (result: Result<APIResponse<EmptyResponse>, NetworkError>) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        self?.showAlert("OTP sent successfully")
                        self?.startResendTimer()
                        self?.clearOTP()
                    } else {
                        self?.showAlert(response.description)
                        self?.resendBtn.isEnabled = true
                        self?.resendBtn.setTitle("Resend OTP", for: .normal)
                    }
                case .failure(let error):
                    self?.handleError(error)
                    self?.resendBtn.isEnabled = true
                    self?.resendBtn.setTitle("Resend OTP", for: .normal)
                }
            }
        }
    }
    
    private func goToSetPasswordVC() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SetPasswordVC") as! SetPasswordVC
        vc.mobileNumber = mobileNumber
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // ✅ Dismiss entire login flow
    private func dismissLoginFlow() {
        navigationController?.dismiss(animated: true)
    }
    
    private func showLoading(_ show: Bool) {
        verifyBtn.isEnabled = !show
        verifyBtn.setTitle(show ? "Verifying..." : "Verify", for: .normal)
        [otpTf1, otpTf2, otpTf3, otpTf4].forEach { $0?.isEnabled = !show }
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func handleError(_ error: NetworkError) {
        switch error {
        case .serverError(let msg): showAlert(msg)
        case .decodingError(let msg): showAlert(msg)
        default: showAlert("Something went wrong. Please try again.")
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        
        if text.count >= 1 {
            switch textField {
            case otpTf1: otpTf2.becomeFirstResponder()
            case otpTf2: otpTf3.becomeFirstResponder()
            case otpTf3: otpTf4.becomeFirstResponder()
            case otpTf4: otpTf4.resignFirstResponder()
            default: break
            }
            
            if text.count > 1 {
                textField.text = String(text.prefix(1))
            }
        }
    }
}

extension OtpVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.isEmpty {
            if textField.text?.isEmpty == true {
                switch textField {
                case otpTf2: otpTf1.becomeFirstResponder()
                case otpTf3: otpTf2.becomeFirstResponder()
                case otpTf4: otpTf3.becomeFirstResponder()
                default: break
                }
            }
            return true
        }
        
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        
        guard allowedCharacters.isSuperset(of: characterSet) else {
            return false
        }
        
        textField.text = string
        
        switch textField {
        case otpTf1: otpTf2.becomeFirstResponder()
        case otpTf2: otpTf3.becomeFirstResponder()
        case otpTf3: otpTf4.becomeFirstResponder()
        case otpTf4: otpTf4.resignFirstResponder()
        default: break
        }
        
        return false
    }
}
