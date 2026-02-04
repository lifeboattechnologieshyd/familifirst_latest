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
        
        mobilenoLbl.text = formatMobileNumber(mobileNumber)
        nameLbl.text = userName ?? "Welcome Back"
        
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
                        self?.navigateToHome()
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
        
        let params: [String: Any] = [
            "mobile": mobileNumber,
            "is_forgot_password": true
        ]
        
        
        NetworkManager.shared.request(
            urlString: API.SEND_OTP,
            method: .POST,
            parameters: params
        ) { [weak self] (result: Result<APIResponse<SendOTPResponse>, NetworkError>) in
            
            DispatchQueue.main.async {
                self?.showLoading(false)
                
                switch result {
                case .success(let response):
                    print("📥 Forgot Password Response: \(response)")
                    
                    if response.success {
                        self?.goToOtpVC(isForgotPassword: true)
                    } else {
                        self?.showAlert(response.description)
                    }
                    
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
    }
    
    private func goToOtpVC(isForgotPassword: Bool = false) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "OtpVC") as! OtpVC
        vc.mobileNumber = mobileNumber
        vc.isForgotPasswordFlow = isForgotPassword
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = storyboard.instantiateViewController(withIdentifier: "CustomTabBarController")
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = homeVC
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }
    
    private func showLoading(_ show: Bool) {
        loginBtn.isEnabled = !show
        forgotPasswordBtn.isEnabled = !show
        loginBtn.setTitle(show ? "Please wait..." : "Login", for: .normal)
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
