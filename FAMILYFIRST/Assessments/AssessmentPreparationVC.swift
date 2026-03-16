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
        
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📱 AssessmentPreparationVC - viewDidLoad")
        print("📱 grade_id: \(grade_id)")
        print("📱 subject_id: \(subject_id)")
        print("📱 selectedLessonIds: \(selectedLessonIds)")
        print("📱 selectedLessonIds count: \(selectedLessonIds.count)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        playLottieFile()
        createAssessment()
    }
    
    func playLottieFile() {
        print("🎬 Playing Lottie animation...")
        
        guard let animationView = imgVw else {
            print("❌ imgVw (LottieAnimationView) is nil!")
            return
        }
        
        guard let animation = LottieAnimation.named("loading") else {
            print("❌ Failed to load 'loading' Lottie animation file!")
            return
        }
        
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.0
        animationView.play()
        print("✅ Lottie animation started")
    }
    
    func goToStartTestVC() {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📱 Navigating to StartTestVC")
        print("📱 Assessment ID: \(createdAssessment?.id ?? "nil")")
        print("📱 Assessment Questions Count: \(createdAssessment?.questions.count ?? 0)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        guard let createdAssessment = createdAssessment else {
            print("❌ Assessment is nil - cannot navigate!")
            showAlert(msg: "Assessment creation failed")
            navigationController?.popViewController(animated: true)
            return
        }
        
        guard let vc = storyboard?.instantiateViewController(identifier: "StartTestVC") as? StartTestVC else {
            print("❌ Failed to instantiate StartTestVC from storyboard!")
            return
        }
        
        vc.assessment = createdAssessment
        print("✅ Pushing to StartTestVC with assessment ID: \(createdAssessment.id)")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func createAssessment() {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📱 createAssessment() called")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        // ── Validation ──────────────────────────────────
        guard !selectedLessonIds.isEmpty else {
            print("❌ selectedLessonIds is EMPTY!")
            showAlert(msg: "Please select at least one lesson")
            navigationController?.popViewController(animated: true)
            return
        }
        
        guard !grade_id.isEmpty, !subject_id.isEmpty else {
            print("❌ Missing required data!")
            print("   grade_id isEmpty: \(grade_id.isEmpty)")
            print("   subject_id isEmpty: \(subject_id.isEmpty)")
            showAlert(msg: "Missing required assessment data. Please try again.")
            navigationController?.popViewController(animated: true)
            return
        }
        
        // ── Build Payload ───────────────────────────────
        let payload: [String: Any] = [
            "grade_id": grade_id,
            "subject_id": subject_id,
            "lesson_ids": selectedLessonIds
        ]
        
        print("📦 Request Payload:")
        print("   grade_id: \(grade_id)")
        print("   subject_id: \(subject_id)")
        print("   lesson_ids: \(selectedLessonIds)")
        
        // ── Build URL ───────────────────────────────────
        let urlString = API.EDUTAIN_CREATE_ASSESSMENT
        print("🌐 API URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            showAlert(msg: "Invalid URL")
            navigationController?.popViewController(animated: true)
            return
        }
        
        // ── Build Request ───────────────────────────────
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let token = UserManager.shared.accessToken
        print("🔑 Token empty: \(token.isEmpty)")
        print("🔑 Token (first 20 chars): \(String(token.prefix(20)))...")
        
        if !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("✅ Authorization header set")
        } else {
            print("⚠️ WARNING: No access token available!")
        }
        
        // ── Encode Body ─────────────────────────────────
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
            request.httpBody = bodyData
            
            if let bodyString = String(data: bodyData, encoding: .utf8) {
                print("📤 Request Body JSON:")
                print(bodyString)
            }
        } catch {
            print("❌ Failed to encode request body: \(error)")
            showAlert(msg: "Failed to encode request")
            navigationController?.popViewController(animated: true)
            return
        }
        
        // ── Print All Request Headers ───────────────────
        print("📋 Request Headers:")
        request.allHTTPHeaderFields?.forEach { key, value in
            if key == "Authorization" {
                print("   \(key): Bearer ***hidden***")
            } else {
                print("   \(key): \(value)")
            }
        }
        
        print("🚀 Sending POST request...")
        
        // ── Network Call ────────────────────────────────
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else {
                print("❌ self is nil (view controller deallocated)")
                return
            }
            
            DispatchQueue.main.async {
                
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("📥 Response received!")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                
                // ── Check HTTP Response ─────────────────
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Status Code: \(httpResponse.statusCode)")
                    print("📡 Content-Type: \(httpResponse.value(forHTTPHeaderField: "Content-Type") ?? "nil")")
                    print("📡 All Response Headers:")
                    httpResponse.allHeaderFields.forEach { key, value in
                        print("   \(key): \(value)")
                    }
                    
                    // ── Handle non-2xx status codes ─────
                    if httpResponse.statusCode == 401 {
                        print("❌ 401 Unauthorized - Token expired or invalid!")
                        self.showAlert(msg: "Session expired. Please login again.")
                        self.performLogout()
                        return
                    }
                    
                    if httpResponse.statusCode == 403 {
                        print("❌ 403 Forbidden - Access denied!")
                        self.showAlert(msg: "Access denied. Please check your permissions.")
                        self.navigationController?.popViewController(animated: true)
                        return
                    }
                    
                    if httpResponse.statusCode == 422 {
                        print("❌ 422 Unprocessable Entity - Validation error!")
                    }
                    
                    if httpResponse.statusCode >= 500 {
                        print("❌ Server error! Status: \(httpResponse.statusCode)")
                    }
                } else {
                    print("⚠️ Response is NOT HTTPURLResponse!")
                }
                
                // ── Check Network Error ─────────────────
                if let error = error {
                    print("❌ Network error: \(error)")
                    print("❌ Error domain: \((error as NSError).domain)")
                    print("❌ Error code: \((error as NSError).code)")
                    print("❌ Error description: \(error.localizedDescription)")
                    self.showAlert(msg: error.localizedDescription)
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                
                // ── Check Data ──────────────────────────
                guard let data = data else {
                    print("❌ No data received from server!")
                    self.showAlert(msg: "No data received")
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                
                print("📦 Data received: \(data.count) bytes")
                
                // ── 🔥 Print RAW Response ───────────────
                if let rawString = String(data: data, encoding: .utf8) {
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("📄 RAW Response Body:")
                    print(rawString)
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    
                    // ── Check if response is empty ──────
                    if rawString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        print("❌ Response body is EMPTY!")
                        self.showAlert(msg: "Server returned empty response")
                        self.navigationController?.popViewController(animated: true)
                        return
                    }
                    
                    // ── Check if response is HTML ───────
                    if rawString.contains("<!DOCTYPE") || rawString.contains("<html") {
                        print("❌ Response is HTML, NOT JSON!")
                        print("❌ Server likely returned an error page")
                        self.showAlert(msg: "Server error. Please try again later.")
                        self.navigationController?.popViewController(animated: true)
                        return
                    }
                    
                    // ── Check if response is plain text ─
                    let trimmed = rawString.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.hasPrefix("{") && !trimmed.hasPrefix("[") {
                        print("❌ Response is NOT JSON!")
                        print("❌ Response starts with: '\(String(trimmed.prefix(50)))'")
                        self.showAlert(msg: "Unexpected server response")
                        self.navigationController?.popViewController(animated: true)
                        return
                    }
                }
                
                // ── Parse JSON ──────────────────────────
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("✅ Valid JSON dictionary received")
                        print("📱 JSON keys: \(json.keys.sorted())")
                        
                        // Print key values for debugging
                        if let success = json["success"] {
                            print("📱 success: \(success) (type: \(type(of: success)))")
                        }
                        if let errorCode = json["errorCode"] {
                            print("📱 errorCode: \(errorCode)")
                        }
                        if let description = json["description"] {
                            print("📱 description: \(description)")
                        }
                        if let message = json["message"] {
                            print("📱 message: \(message)")
                        }
                        
                        // ── Check Success ───────────────
                        if let success = json["success"] as? Bool, success {
                            print("✅ API returned success = true")
                            
                            // ── Try "data" as Array ─────
                            if let dataArray = json["data"] as? [[String: Any]] {
                                print("📱 data is Array with \(dataArray.count) items")
                                
                                guard let firstAssessment = dataArray.first else {
                                    print("❌ Data array is EMPTY!")
                                    self.showAlert(msg: "No assessment created")
                                    self.navigationController?.popViewController(animated: true)
                                    return
                                }
                                
                                print("📱 First assessment keys: \(firstAssessment.keys.sorted())")
                                print("📱 First assessment raw:")
                                firstAssessment.forEach { key, value in
                                    if let arrayValue = value as? [Any] {
                                        print("   \(key): Array[\(arrayValue.count) items]")
                                    } else {
                                        print("   \(key): \(value)")
                                    }
                                }
                                
                                let assessmentData = try JSONSerialization.data(withJSONObject: firstAssessment, options: [])
                                print("📱 Re-serialized assessment data: \(assessmentData.count) bytes")
                                
                                let decoder = JSONDecoder()
                                let assessment = try decoder.decode(Assessment.self, from: assessmentData)
                                
                                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                                print("✅ Assessment parsed successfully!")
                                print("   ID: \(assessment.id)")
                                print("   Questions: \(assessment.questions.count)")
                                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                                
                                self.createdAssessment = assessment
                                self.goToStartTestVC()
                                
                            }
                            // ── Try "data" as Dictionary ─
                            else if let dataDict = json["data"] as? [String: Any] {
                                print("📱 data is Dictionary (not array)")
                                print("📱 data keys: \(dataDict.keys.sorted())")
                                
                                dataDict.forEach { key, value in
                                    if let arrayValue = value as? [Any] {
                                        print("   \(key): Array[\(arrayValue.count) items]")
                                    } else {
                                        print("   \(key): \(value)")
                                    }
                                }
                                
                                let assessmentData = try JSONSerialization.data(withJSONObject: dataDict, options: [])
                                let decoder = JSONDecoder()
                                let assessment = try decoder.decode(Assessment.self, from: assessmentData)
                                
                                print("✅ Assessment parsed from dictionary!")
                                print("   ID: \(assessment.id)")
                                print("   Questions: \(assessment.questions.count)")
                                
                                self.createdAssessment = assessment
                                self.goToStartTestVC()
                                
                            } else {
                                print("❌ 'data' field is nil or unexpected type")
                                print("📱 data value: \(String(describing: json["data"]))")
                                print("📱 data type: \(type(of: json["data"]))")
                                self.showAlert(msg: "No assessment data received")
                                self.navigationController?.popViewController(animated: true)
                            }
                            
                        } else {
                            print("❌ API returned success = false (or missing)")
                            let desc = json["description"] as? String ?? "Unknown error"
                            let msg = json["message"] as? String ?? desc
                            print("❌ Error message: \(msg)")
                            self.showAlert(msg: msg)
                            self.navigationController?.popViewController(animated: true)
                        }
                        
                    } else if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] {
                        print("⚠️ Response is a JSON Array (unexpected)")
                        print("📱 Array count: \(jsonArray.count)")
                        self.showAlert(msg: "Unexpected response format")
                        self.navigationController?.popViewController(animated: true)
                        
                    } else {
                        print("❌ Could not parse JSON as dictionary or array")
                        self.showAlert(msg: "Invalid response format")
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                } catch {
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("❌ JSON Parsing FAILED!")
                    print("❌ Error: \(error)")
                    print("❌ Localized: \(error.localizedDescription)")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .keyNotFound(let key, let context):
                            print("❌ DECODING - Missing key: '\(key.stringValue)'")
                            print("   Path: \(context.codingPath.map { $0.stringValue }.joined(separator: " → "))")
                            print("   Debug: \(context.debugDescription)")
                        case .typeMismatch(let type, let context):
                            print("❌ DECODING - Type mismatch!")
                            print("   Expected: \(type)")
                            print("   Path: \(context.codingPath.map { $0.stringValue }.joined(separator: " → "))")
                            print("   Debug: \(context.debugDescription)")
                        case .valueNotFound(let type, let context):
                            print("❌ DECODING - Value not found!")
                            print("   Expected: \(type)")
                            print("   Path: \(context.codingPath.map { $0.stringValue }.joined(separator: " → "))")
                            print("   Debug: \(context.debugDescription)")
                        case .dataCorrupted(let context):
                            print("❌ DECODING - Data corrupted!")
                            print("   Path: \(context.codingPath.map { $0.stringValue }.joined(separator: " → "))")
                            print("   Debug: \(context.debugDescription)")
                        @unknown default:
                            print("❌ DECODING - Unknown error")
                        }
                    }
                    
                    if let nsError = error as NSError? {
                        print("❌ NSError domain: \(nsError.domain)")
                        print("❌ NSError code: \(nsError.code)")
                        print("❌ NSError userInfo: \(nsError.userInfo)")
                    }
                    
                    self.showAlert(msg: "Error parsing assessment data")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }.resume()
        
        print("🚀 Request sent! Waiting for response...")
    }
    
    func performLogout() {
        print("🔒 Performing logout...")
        UserManager.shared.logout()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
            let navController = UINavigationController(rootViewController: loginVC)
            navController.modalPresentationStyle = .fullScreen
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = navController
                window.makeKeyAndVisible()
                print("✅ Logged out and navigated to LoginVC")
            }
        }
    }
}
