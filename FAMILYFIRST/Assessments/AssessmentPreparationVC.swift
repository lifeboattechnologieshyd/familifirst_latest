//
//  AssessmentPreparationVC.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 11/10/25.
//

import UIKit
import Lottie

class AssessmentPreparationVC: UIViewController {
    
    @IBOutlet weak var imgVw: LottieAnimationView!
    
    var grade_id = ""
    var subject_id = ""
    var selectedLessonIds: [String] = []
    var createdAssessment: Assessment?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playLottieFile()
        createAssessment()
    }
    
    func playLottieFile() {
        guard let animationView = imgVw else { return }
        
        guard let animation = LottieAnimation.named("loading") else {
            return
        }
        
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.0
        animationView.play()
    }
    
    func goToStartTestVC() {
        guard let vc = storyboard?.instantiateViewController(identifier: "StartTestVC") as? StartTestVC else {
            return
        }
        vc.assessment = createdAssessment
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func createAssessment() {
        guard let userId = UserManager.shared.userId else {
            showAlert(msg: "User ID not found. Please login again.")
            navigationController?.popViewController(animated: true)
            return
        }
        
        guard !selectedLessonIds.isEmpty else {
            showAlert(msg: "Please select at least one lesson")
            navigationController?.popViewController(animated: true)
            return
        }
        
        guard !grade_id.isEmpty, !subject_id.isEmpty else {
            showAlert(msg: "Missing required assessment data. Please try again.")
            navigationController?.popViewController(animated: true)
            return
        }
        
        let payload: [String: Any] = [
            "grade_id": grade_id,
            "subject_id": subject_id,
            "lesson_ids": selectedLessonIds,
            "user_id": userId
        ]
        
        NetworkManager.shared.request(urlString: API.EDUTAIN_CREATE_ASSESSMENT, method: .POST, parameters: payload) { [weak self] (result: Result<APIResponse<[Assessment]>, NetworkError>) in
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let info):
                    if info.success, let data = info.data, let assessment = data.first {
                        self.createdAssessment = assessment
                        self.goToStartTestVC()
                    } else {
                        self.showAlert(msg: info.description)
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                case .failure(let error):
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
