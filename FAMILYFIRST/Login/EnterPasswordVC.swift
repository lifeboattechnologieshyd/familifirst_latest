//
//  EnterPasswordVC.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 28/01/26.
//
import UIKit

class EnterPasswordVC: UIViewController {

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var imageVw: UIImageView!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    @IBOutlet weak var mobilenoLbl: UILabel!
    @IBOutlet weak var viewBtn: UIButton!
    
    var mobileNumber: String = ""
    var userName: String?
    var profileImageURL: String?
    
    private var isPasswordVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        passwordTf.isSecureTextEntry = true
        viewBtn.setImage(UIImage(systemName: "closeEye"), for: .normal)
        
        // Display mobile number
        mobilenoLbl.text = formatMobileNumber(mobileNumber)
        
        // Display user name
        nameLbl.text = userName ?? "Welcome Back"
        
        // Load profile image if available
        if let imageURL = profileImageURL, !imageURL.isEmpty {
            loadImage(from: imageURL)
        } else {
            imageVw.image = UIImage(systemName: "person.circle.fill")
        }
    }
    
    private func formatMobileNumber(_ number: String) -> String {
        if number.count == 10 {
            let masked = String(repeating: "*", count: 6) + String(number.suffix(4))
            return "+91 " + masked
        }
        return number
    }
    
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.imageVw.image = image
                }
            }
        }.resume()
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func viewBtnTapped(_ sender: UIButton) {
        isPasswordVisible.toggle()
        passwordTf.isSecureTextEntry = !isPasswordVisible
        
        let imageName = isPasswordVisible ? "view" : "closeEye"
        viewBtn.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @IBAction func loginBtnTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        guard let password = passwordTf.text?.trimmingCharacters(in: .whitespaces),
              !password.isEmpty else {
            showAlert("Please enter password")
            return
        }
        
        loginWithPassword(password: password)
    }
    
    @IBAction func forgotPasswordBtnTapped(_ sender: UIButton) {
        // Go to OTP screen for forgot password
        forgotPassword()
    }
    
    private func loginWithPassword(password: String) {
        showLoading(true)
        
        let params: [String: Any] = [
            "mobile": mobileNumber,
            "password": password
        ]
        
        NetworkManager.shared.request(
            urlString: API.LOGIN_PASSWORD,
            method: .POST,
            parameters: params
        ) { [weak self] (result: Result<APIResponse<VerifyOTPResponse>, NetworkError>) in
            
            DispatchQueue.main.async {
                self?.showLoading(false)
                
                switch result {
                case .success(let response):
                    if response.success {
                        if let data = response.data,
                           let access = data.accessToken,
                           let refresh = data.refreshToken {
                            UserManager.shared.saveTokens(access: access, refresh: refresh)
                        }
                        
                        self?.goToHome()
                        
                    } else {
                        self?.showAlert(response.description)
                        self?.passwordTf.text = ""
                    }
                    
                case .failure(let error):
                    self?.handleError(error)
                    self?.passwordTf.text = ""
                }
            }
        }
    }
    
    private func forgotPassword() {
        showLoading(true)
        
        let params: [String: Any] = ["mobile": mobileNumber]
        
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
                        // Go to OTP screen
                        self?.goToOtpVC()
                    } else {
                        self?.showAlert(response.description)
                    }
                    
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
    }
    
    private func goToOtpVC() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "OtpVC") as! OtpVC
        vc.mobileNumber = mobileNumber
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func goToHome() {
        if let tabBarVC = storyboard?.instantiateViewController(withIdentifier: "CustomTabBarController") {
            tabBarVC.modalPresentationStyle = .fullScreen
            present(tabBarVC, animated: true)
        }
    }
    
    private func showLoading(_ show: Bool) {
        loginBtn.isEnabled = !show
        loginBtn.setTitle(show ? "Logging in..." : "Login", for: .normal)
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func handleError(_ error: NetworkError) {
        switch error {
        case .serverError(let msg): showAlert(msg)
        case .noaccess: showAlert("Invalid password. Please try again.")
        default: showAlert("Something went wrong. Please try again.")
        }
    }
}
