//
//  LoginVC.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 28/01/26.
//
import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var mobileTf: UITextField!
    @IBOutlet weak var getotpBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        mobileTf.keyboardType = .phonePad
        mobileTf.delegate = self
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func getOTPBtnTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        guard let mobile = mobileTf.text?.trimmingCharacters(in: .whitespaces),
              !mobile.isEmpty else {
            showAlert("Please enter mobile number")
            return
        }
        
        guard mobile.count == 10, mobile.allSatisfy({ $0.isNumber }) else {
            showAlert("Please enter valid 10 digit mobile number")
            return
        }
        
        sendOTP(mobile: mobile)
    }
    
    private func sendOTP(mobile: String) {
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
                        // Save mobile number
                        UserManager.shared.saveMobile(mobile)
                        
                        if let data = response.data, data.passwordRequired {
                            // Existing user with password → EnterPasswordVC
                            self?.goToEnterPasswordVC(mobile: mobile)
                        } else {
                            // New user or no password → OtpVC
                            self?.goToOtpVC(mobile: mobile)
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
    
    private func goToOtpVC(mobile: String) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "OtpVC") as! OtpVC
        vc.mobileNumber = mobile
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func goToEnterPasswordVC(mobile: String) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "EnterPasswordVC") as! EnterPasswordVC
        vc.mobileNumber = mobile
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
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        
        let currentText = textField.text ?? ""
        let newLength = currentText.count + string.count - range.length
        
        return allowedCharacters.isSuperset(of: characterSet) && newLength <= 10
    }
}
