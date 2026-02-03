//
//  SetPasswordVC.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 28/01/26.
//

import UIKit

class SetPasswordVC: UIViewController {

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var confirmPasswordTf: UITextField!
    @IBOutlet weak var passwordViewBtn: UIButton!
    @IBOutlet weak var confirmPasswordViewBtn: UIButton!
    @IBOutlet weak var createPasswordBtn: UIButton!
    
    var mobileNumber: String = ""
    
    private var isPasswordVisible = false
    private var isConfirmPasswordVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        passwordTf.isSecureTextEntry = true
        confirmPasswordTf.isSecureTextEntry = true
        
        passwordViewBtn.setImage(UIImage(systemName: "view"), for: .normal)
        confirmPasswordViewBtn.setImage(UIImage(systemName: "view"), for: .normal)
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func passwordViewBtnTapped(_ sender: UIButton) {
        isPasswordVisible.toggle()
        passwordTf.isSecureTextEntry = !isPasswordVisible
        
        let imageName = isPasswordVisible ? "view" : "closeEye"
        passwordViewBtn.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @IBAction func confirmPasswordViewBtnTapped(_ sender: UIButton) {
        isConfirmPasswordVisible.toggle()
        confirmPasswordTf.isSecureTextEntry = !isConfirmPasswordVisible
        
        let imageName = isConfirmPasswordVisible ? "view" : "closeEye"
        confirmPasswordViewBtn.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @IBAction func createPasswordBtnTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        guard let password = passwordTf.text?.trimmingCharacters(in: .whitespaces),
              !password.isEmpty else {
            showAlert("Please enter password")
            return
        }
        
        guard let confirmPassword = confirmPasswordTf.text?.trimmingCharacters(in: .whitespaces),
              !confirmPassword.isEmpty else {
            showAlert("Please confirm password")
            return
        }
        
        guard password == confirmPassword else {
            showAlert("Passwords do not match")
            return
        }
        
        // Validate password format
        guard isValidPassword(password) else {
            showAlert("Password must be at least 6 characters, start with a capital letter, include one number and one special character.")
            return
        }
        
        setPassword(password: password, confirmPassword: confirmPassword)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        // At least 6 characters
        guard password.count >= 6 else { return false }
        
        // Starts with capital letter
        guard let firstChar = password.first, firstChar.isUppercase else { return false }
        
        // Contains at least one number
        let hasNumber = password.contains { $0.isNumber }
        guard hasNumber else { return false }
        
        // Contains at least one special character
        let specialCharacters = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;':\",./<>?")
        let hasSpecial = password.unicodeScalars.contains { specialCharacters.contains($0) }
        guard hasSpecial else { return false }
        
        return true
    }
    
    private func setPassword(password: String, confirmPassword: String) {
        showLoading(true)
        
        let params: [String: Any] = [
            "mobile": mobileNumber,
            "password": password,
            "confirm_password": confirmPassword
        ]
        
        NetworkManager.shared.request(
            urlString: API.SET_PASSWORD,
            method: .POST,
            parameters: params
        ) { [weak self] (result: Result<APIResponse<VerifyOTPResponse>, NetworkError>) in
            
            DispatchQueue.main.async {
                self?.showLoading(false)
                
                switch result {
                case .success(let response):
                    if response.success {
                        // Save tokens if available
                        if let data = response.data,
                           let access = data.accessToken,
                           let refresh = data.refreshToken {
                            UserManager.shared.saveTokens(access: access, refresh: refresh)
                        }
                        
                        self?.goToHome()
                        
                    } else {
                        self?.showAlert(response.description)
                    }
                    
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
    }
    
    private func goToHome() {
        if let tabBarVC = storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") {
            tabBarVC.modalPresentationStyle = .fullScreen
            present(tabBarVC, animated: true)
        }
        
      
    }
    
    private func showLoading(_ show: Bool) {
        createPasswordBtn.isEnabled = !show
        createPasswordBtn.setTitle(show ? "Creating..." : "Create Password", for: .normal)
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
