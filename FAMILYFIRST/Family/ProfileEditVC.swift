//
//  ProfileEditVC.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 17/02/26.
//

import UIKit

class ProfileEditVC: UIViewController {
    
    @IBOutlet weak var referCodeLbl: UILabel!
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var telegramBtn: UIImageView!
    @IBOutlet weak var viewone: UIView!
    @IBOutlet weak var facebookBtn: UIImageView!
    @IBOutlet weak var viewtwo: UIView!
    @IBOutlet weak var twitterBtn: UIImageView!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var referVw: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var dobTF: UITextField!
    @IBOutlet weak var viewthree: UIView!
    @IBOutlet weak var phonenumberTf: UITextField!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var deleteAccountBtn: UIButton!
    @IBOutlet weak var instagramBtn: UIImageView!
    @IBOutlet weak var whatsappBtn: UIImageView!
    
    private var userDetails: UserDetails?
    private let datePicker = UIDatePicker()
    private var referralCode: String = ""
    
    var onProfileUpdated: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topVw.addBottomShadow()
        viewone.addCardShadow()
        viewtwo.addCardShadow()
        viewthree.addCardShadow()
        referVw.addDashedBorder()
        nameTf.addCardShadow()
        dobTF.addCardShadow()
        phonenumberTf.addCardShadow()

        setupUI()
        setupDatePicker()
        setupSocialMediaGestures()
        
        if let savedDOB = UserDefaults.standard.string(forKey: "savedDOB"), !savedDOB.isEmpty {
            dobTF.text = savedDOB
        }
        
        fetchUserDetails()
    }
    
    private func setupUI() {
        imgVw.layer.cornerRadius = imgVw.frame.height / 2
        imgVw.clipsToBounds = true
        
        nameTf.delegate = self
        phonenumberTf.delegate = self
        dobTF.delegate = self
        
        phonenumberTf.keyboardType = .phonePad
        phonenumberTf.isUserInteractionEnabled = false
        phonenumberTf.textColor = .gray
    }
    
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        
        let calendar = Calendar.current
        if let minDate = calendar.date(byAdding: .year, value: -100, to: Date()) {
            datePicker.minimumDate = minDate
        }
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(datePickerDone))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(datePickerCancel))
        
        toolbar.setItems([cancelButton, flexSpace, doneButton], animated: false)
        
        dobTF.inputView = datePicker
        dobTF.inputAccessoryView = toolbar
    }
    
    private func setupSocialMediaGestures() {
        telegramBtn.isUserInteractionEnabled = true
        telegramBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(telegramTapped)))
        
        facebookBtn.isUserInteractionEnabled = true
        facebookBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(facebookTapped)))
        
        twitterBtn.isUserInteractionEnabled = true
        twitterBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(twitterTapped)))
        
        instagramBtn.isUserInteractionEnabled = true
        instagramBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(instagramTapped)))
        
        whatsappBtn.isUserInteractionEnabled = true
        whatsappBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(whatsappTapped)))
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func updateBtnTapped(_ sender: UIButton) {
        updateUserDetails()
    }
    
    @IBAction func deleteAccountBtnTapped(_ sender: UIButton) {
        showDeleteAlert()
    }
    
    @objc private func datePickerDone() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dobTF.text = formatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
    @objc private func datePickerCancel() {
        view.endEditing(true)
    }
    
    @objc private func telegramTapped() {
        shareToTelegram()
    }
    
    @objc private func facebookTapped() {
        shareToFacebook()
    }
    
    @objc private func twitterTapped() {
        shareToTwitter()
    }
    
    @objc private func instagramTapped() {
        shareToInstagram()
    }
    
    @objc private func whatsappTapped() {
        shareToWhatsApp()
    }
    
    private func getShareMessage() -> String {
        return "Join FamilyFirst app using my referral code: \(referralCode). Download now!"
    }
    
    private func shareToTelegram() {
        let message = getShareMessage()
        let urlString = "tg://msg?text=\(message)"
        if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encoded) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                showAlert(title: "Error", message: "Telegram is not installed")
            }
        }
    }
    
    private func shareToFacebook() {
        let message = getShareMessage()
        let urlString = "fb://composer?text=\(message)"
        if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encoded) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                if let webUrl = URL(string: "https://www.facebook.com/sharer/sharer.php?quote=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
                    UIApplication.shared.open(webUrl)
                }
            }
        }
    }
    
    private func shareToTwitter() {
        let message = getShareMessage()
        let urlString = "twitter://post?message=\(message)"
        if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encoded) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                if let webUrl = URL(string: "https://twitter.com/intent/tweet?text=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
                    UIApplication.shared.open(webUrl)
                }
            }
        }
    }
    
    private func shareToInstagram() {
        let message = getShareMessage()
        UIPasteboard.general.string = message
        
        if let url = URL(string: "instagram://app") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                showAlert(title: "Copied!", message: "Referral message copied. Paste it in Instagram.")
            } else {
                showAlert(title: "Error", message: "Instagram is not installed")
            }
        }
    }
    
    private func shareToWhatsApp() {
        let message = getShareMessage()
        let urlString = "whatsapp://send?text=\(message)"
        if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encoded) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                showAlert(title: "Error", message: "WhatsApp is not installed")
            }
        }
    }
    
    private func fetchUserDetails() {
        let mobile = UserManager.shared.mobile
        let email = UserManager.shared.email
        
        var urlString = API.USER_DETAILS
        
        if !mobile.isEmpty {
            urlString += "?mobile=\(mobile)"
        } else if !email.isEmpty {
            urlString += "?email=\(email)"
        } else if let userId = UserManager.shared.userId {
            urlString += "?id=\(userId)"
        } else {
            showAlert(title: "Error", message: "No user information found")
            return
        }
        
        NetworkManager.shared.request(
            urlString: urlString,
            method: .GET
        ) { [weak self] (result: Result<APIResponse<UserDetails>, NetworkError>) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        self?.userDetails = data
                        self?.populateData(data)
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
    
    private func populateData(_ user: UserDetails) {
        if let firstName = user.firstName, !firstName.isEmpty {
            if let lastName = user.lastName, !lastName.isEmpty {
                nameTf.text = "\(firstName) \(lastName)"
            } else {
                nameTf.text = firstName
            }
        } else if let lastName = user.lastName, !lastName.isEmpty {
            nameTf.text = lastName
        } else {
            nameTf.text = user.username ?? ""
        }
        
        referralCode = user.referralCode ?? ""
        referCodeLbl.text = user.referralCode ?? "N/A"
        
        if let mobile = user.mobile {
            phonenumberTf.text = "\(mobile)"
        } else if let email = user.email, !email.isEmpty {
            phonenumberTf.text = email
        } else {
            let savedMobile = UserManager.shared.mobile
            if !savedMobile.isEmpty {
                phonenumberTf.text = savedMobile
            }
        }
        
        if let savedDOB = UserDefaults.standard.string(forKey: "savedDOB"), !savedDOB.isEmpty {
            dobTF.text = savedDOB
        }
        
        if let imageUrl = user.profileImage, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
            loadImage(from: url)
        } else {
            imgVw.image = UIImage(named: "Picture")
        }
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.imgVw.image = UIImage(named: "Picture")
                }
                return
            }
            DispatchQueue.main.async {
                self?.imgVw.image = UIImage(data: data)
            }
        }.resume()
    }
    
    private func updateUserDetails() {
        view.endEditing(true)
        
        guard validateInputs() else { return }
        
        let mobile = UserManager.shared.mobile
        let email = UserManager.shared.email
        
        var parameters: [String: Any] = [:]
        
        if !mobile.isEmpty {
            parameters["mobile"] = mobile
        } else if !email.isEmpty {
            parameters["email"] = email
        } else if let userId = UserManager.shared.userId {
            parameters["id"] = userId
        } else {
            showAlert(title: "Error", message: "No user information found")
            return
        }
        
        if let fullName = nameTf.text, !fullName.isEmpty {
            let nameParts = fullName.split(separator: " ")
            if nameParts.count > 0 {
                parameters["first_name"] = String(nameParts[0])
            }
            if nameParts.count > 1 {
                parameters["last_name"] = nameParts.dropFirst().joined(separator: " ")
            }
        }
        
        if let dob = dobTF.text, !dob.isEmpty {
            parameters["date_of_birth"] = convertDateToAPIFormat(dob)
        }
        
        NetworkManager.shared.request(
            urlString: API.USER_DETAILS,
            method: .PUT,
            parameters: parameters
        ) { [weak self] (result: Result<APIResponse<UserDetails>, NetworkError>) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        
                        if let dobText = self?.dobTF.text, !dobText.isEmpty {
                            UserDefaults.standard.set(dobText, forKey: "savedDOB")
                        }
                        
                        self?.onProfileUpdated?()
                        self?.showAlert(title: "Success", message: "Profile updated successfully") {
                            self?.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        self?.showAlert(title: "Error", message: response.description ?? "Update failed")
                    }
                case .failure(let error):
                    self?.showAlert(title: "Error", message: "Something went wrong")
                    print("Error: \(error)")
                }
            }
        }
    }
    
    private func validateInputs() -> Bool {
        guard let name = nameTf.text, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert(title: "Error", message: "Please enter your name")
            return false
        }
        return true
    }
    
    private func showDeleteAlert() {
        let alert = UIAlertController(
            title: "Delete Account",
            message: "Are you sure you want to delete your account?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "OK", style: .destructive) { [weak self] _ in
            self?.showDeleteConfirmationMessage()
        })
        
        present(alert, animated: true)
    }
    
    private func showDeleteConfirmationMessage() {
        let alert = UIAlertController(
            title: "Request Submitted",
            message: "Your account will be deleted soon.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        UserManager.shared.logout()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC else { return }
        
        let nav = UINavigationController(rootViewController: loginVC)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .fullScreen
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = nav
            window.makeKeyAndVisible()
        }
    }
    
    private func convertDateToAPIFormat(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd/MM/yyyy"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        
        return dateString
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

extension ProfileEditVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTf {
            dobTF.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
