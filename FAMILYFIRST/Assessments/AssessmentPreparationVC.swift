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
        print("📱 Navigating to StartTestVC")
        print("📱 Assessment: \(createdAssessment?.id ?? "nil")")
        
        guard let createdAssessment = createdAssessment else {
            print("❌ Assessment is nil")
            showAlert(msg: "Assessment creation failed")
            navigationController?.popViewController(animated: true)
            return
        }
        
        guard let vc = storyboard?.instantiateViewController(identifier: "StartTestVC") as? StartTestVC else {
            print("❌ Failed to instantiate StartTestVC")
            return
        }
        
        vc.assessment = createdAssessment
        print("✅ Pushing to StartTestVC")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func createAssessment() {
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
        
        print("📱 Creating assessment...")
        
        let payload: [String: Any] = [
            "grade_id": grade_id,
            "subject_id": subject_id,
            "lesson_ids": selectedLessonIds
        ]
        
        guard let url = URL(string: API.EDUTAIN_CREATE_ASSESSMENT) else {
            showAlert(msg: "Invalid URL")
            navigationController?.popViewController(animated: true)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Fixed: accessToken is String, not Optional
        let token = UserManager.shared.accessToken
        if !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            showAlert(msg: "Failed to encode request")
            navigationController?.popViewController(animated: true)
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Network error: \(error)")
                    self.showAlert(msg: error.localizedDescription)
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    self.showAlert(msg: "No data received")
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("📱 Received JSON response")
                        
                        if let success = json["success"] as? Bool, success {
                            if let dataArray = json["data"] as? [[String: Any]], let firstAssessment = dataArray.first {
                                
                                print("📱 Parsing assessment from JSON...")
                                
                                let assessmentData = try JSONSerialization.data(withJSONObject: firstAssessment, options: [])
                                let decoder = JSONDecoder()
                                let assessment = try decoder.decode(Assessment.self, from: assessmentData)
                                
                                print("✅ Assessment parsed successfully!")
                                print("   ID: \(assessment.id)")
                                print("   Questions: \(assessment.questions.count)")
                                
                                self.createdAssessment = assessment
                                self.goToStartTestVC()
                                
                            } else {
                                print("❌ Data array is empty")
                                self.showAlert(msg: "No assessment created")
                                self.navigationController?.popViewController(animated: true)
                            }
                        } else {
                            print("❌ API returned success = false")
                            self.showAlert(msg: "Failed to create assessment")
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                } catch {
                    print("❌ JSON Parsing error: \(error)")
                    print("❌ Error details: \(error.localizedDescription)")
                    
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .keyNotFound(let key, let context):
                            print("❌ Missing key: \(key.stringValue)")
                            print("❌ Context: \(context.debugDescription)")
                        case .typeMismatch(let type, let context):
                            print("❌ Type mismatch for type: \(type)")
                            print("❌ Context: \(context.debugDescription)")
                        case .valueNotFound(let type, let context):
                            print("❌ Value not found for type: \(type)")
                            print("❌ Context: \(context.debugDescription)")
                        case .dataCorrupted(let context):
                            print("❌ Data corrupted: \(context.debugDescription)")
                        @unknown default:
                            print("❌ Unknown decoding error")
                        }
                    }
                    
                    self.showAlert(msg: "Error parsing assessment data")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }.resume()
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
