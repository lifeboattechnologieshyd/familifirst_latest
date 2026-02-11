//
//  LoginVC.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 28/01/26.
//
import UIKit

class LoginVC: UIViewController {
    
    enum LoginType {
        case mobile
        case email
    }

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var mobileTf: UITextField!
    @IBOutlet weak var textLbl: UILabel!
    @IBOutlet weak var getotpBtn: UIButton!
    @IBOutlet weak var codeLbl: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    
    private var currentLoginType: LoginType = .mobile
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        selectMobileLogin()
    }
    
    private func setupUI() {
        mobileTf.delegate = self
        mobileTf.addLeftPadding(40)
        backBtn.isHidden = true
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func loginBtnTapped(_ sender: UIButton) {
        switch currentLoginType {
        case .mobile:
            selectEmailLogin()
        case .email:
            selectMobileLogin()
        }
    }
    
    @IBAction func getOTPBtnTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        switch currentLoginType {
        case .mobile:
            validateAndSendMobileOTP()
        case .email:
            validateAndSendEmailOTP()
        }
    }
    
    private func selectMobileLogin() {
        currentLoginType = .mobile
        codeLbl.isHidden = false
        mobileTf.text = ""
        mobileTf.placeholder = "Enter Mobile Number"
        mobileTf.keyboardType = .phonePad
        mobileTf.reloadInputViews()
        
        textLbl.text = "Enter your Indian Mobile Number"
        loginBtn.setTitle("Login with E-mail instead", for: .normal)
    }
    
    private func selectEmailLogin() {
        currentLoginType = .email
        
        codeLbl.isHidden = true
        mobileTf.text = ""
        mobileTf.placeholder = "Enter Email Address"
        mobileTf.keyboardType = .emailAddress
        mobileTf.reloadInputViews()
        
        textLbl.text = "Enter your Email ID"
        loginBtn.setTitle("Login with Indian Mobile instead", for: .normal)
    }
    
    private func validateAndSendMobileOTP() {
        guard let mobile = mobileTf.text?.trimmingCharacters(in: .whitespaces),
              !mobile.isEmpty else {
            showAlert("Please enter mobile number")
            return
        }
        
        guard mobile.count == 10, mobile.allSatisfy({ $0.isNumber }) else {
            showAlert("Please enter valid 10 digit mobile number")
            return
        }
        
        sendMobileOTP(mobile: mobile)
    }
    
    private func validateAndSendEmailOTP() {
        guard let email = mobileTf.text?.trimmingCharacters(in: .whitespaces),
              !email.isEmpty else {
            showAlert("Please enter email address")
            return
        }
        
        guard isValidEmail(email) else {
            showAlert("Please enter a valid email address")
            return
        }
        
        sendEmailOTP(email: email)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func sendMobileOTP(mobile: String) {
        showLoading(true)
        
        let params: [String: Any] = ["mobile": mobile]
        
        NetworkManager.shared.request(
            urlString: API.SEND_OTP,
            method: .POST,
            parameters: params
        ) { [weak self] (result: Result<APIResponse<SendOTPResponse>, NetworkError>) in
            
            DispatchQueue.main.async {
                self?.showLoading(false)
                
                switch result {
                case .success(let response):
                    if response.success {
                        UserManager.shared.saveMobile(mobile)
                        
                        if let data = response.data, data.passwordRequired {
                            self?.goToEnterPasswordVC(mobile: mobile)
                        } else {
                            self?.goToOtpVC(identifier: mobile, loginType: .mobile)
                        }
                    } else {
                        self?.showAlert(response.description)
                    }
                    
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
    }
    
    private func sendEmailOTP(email: String) {
        showLoading(true)
        
        let params: [String: Any] = [
            "email": email,
            "is_forgot_password": false
        ]
        
        NetworkManager.shared.request(
            urlString: API.EMAIL_SEND_OTP,
            method: .POST,
            parameters: params
        ) { [weak self] (result: Result<APIResponse<EmailSendOTPResponse>, NetworkError>) in
            
            DispatchQueue.main.async {
                self?.showLoading(false)
                
                switch result {
                case .success(let response):
                    if response.success {
                        UserManager.shared.saveEmail(email)
                        
                        if let data = response.data, data.passwordRequired == true {
                            self?.goToEnterPasswordVCWithEmail(email: email)
                        } else {
                            self?.goToOtpVC(identifier: email, loginType: .email)
                        }
                    } else {
                        self?.showAlert(response.description)
                    }
                    
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
    }
    
    private func goToOtpVC(identifier: String, loginType: LoginType) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "OtpVC") as! OtpVC
        
        switch loginType {
        case .mobile:
            vc.mobileNumber = identifier
            vc.loginType = .mobile
        case .email:
            vc.emailAddress = identifier
            vc.loginType = .email
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func goToEnterPasswordVC(mobile: String) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "EnterPasswordVC") as! EnterPasswordVC
        vc.mobileNumber = mobile
        vc.loginType = .mobile
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func goToEnterPasswordVCWithEmail(email: String) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "EnterPasswordVC") as! EnterPasswordVC
        vc.emailAddress = email
        vc.loginType = .email
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showLoading(_ show: Bool) {
        getotpBtn.isEnabled = !show
        getotpBtn.setTitle(show ? "Sending..." : "Get OTP", for: .normal)
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
}

extension LoginVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        switch currentLoginType {
        case .mobile:
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            
            let currentText = textField.text ?? ""
            let newLength = currentText.count + string.count - range.length
            
            return allowedCharacters.isSuperset(of: characterSet) && newLength <= 10
            
        case .email:
            return true
        }
    }
}
