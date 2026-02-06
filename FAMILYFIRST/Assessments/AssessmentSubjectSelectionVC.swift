//
//  AssessmentSubjectSelectionVC.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 11/10/25.
//

import UIKit

class AssessmentSubjectSelectionVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var colVw: UICollectionView!
    var grade_id = ""
    var subjects = [GradeSubject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getSubjects()
        self.colVw.register(UINib(nibName: "SubjectCollectionCell", bundle: nil), forCellWithReuseIdentifier: "SubjectCollectionCell")
        colVw.delegate = self
        colVw.dataSource = self
    }
    
    
    func getSubjects() {
        guard let userId = UserManager.shared.userId else {
            print("❌ Error: userId not found in UserManager")
            self.showAlert(msg: "User ID not found. Please login again.")
            return
        }
        
        guard !grade_id.isEmpty else {
            print("❌ Error: grade_id is empty")
            self.showAlert(msg: "Grade not selected. Please go back and select a grade.")
            return
        }
        
        print("📱 Fetching subjects for userId: \(userId), grade_id: \(grade_id)")
        
        showLoader()
        
        let subject_url = "\(API.EDUTAIN_SUBJECTS)?grade=\(grade_id)&user_id=\(userId)"
        
        NetworkManager.shared.request(urlString: subject_url, method: .GET) { (result: Result<APIResponse<[GradeSubject]>, NetworkError>) in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        DispatchQueue.main.async {
                            self.subjects = data
                            self.colVw.reloadData()
                            self.hideLoader()
                            print("✅ Successfully loaded \(self.subjects.count) subjects")
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.hideLoader()
                            print("⚠️ No subjects data received")
                            self.showAlert(msg: "No subjects available for this grade")
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.hideLoader()
                        print("❌ API Error: \(info.description)")
                        self.showAlert(msg: info.description)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.hideLoader()
                    switch error {
                    case .noaccess:
                        self.performLogout()
                    default:
                        self.showAlert(msg: error.localizedDescription)
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

    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}


extension AssessmentSubjectSelectionVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.subjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubjectCollectionCell", for: indexPath) as! SubjectCollectionCell
        cell.imgVw.loadImage(url: self.subjects[indexPath.row].subjectImage)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (colVw.frame.size.width - 10) / 2, height: (colVw.frame.size.width - 10) / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(identifier: "AssessmentLessonVC") as? AssessmentLessonVC else {
            print("❌ Error: Could not instantiate AssessmentLessonVC")
            return
        }
        
        vc.grade_id = grade_id
        vc.subject_id = self.subjects[indexPath.row].id
        
         
        print("✅ Navigating to lesson with grade_id: \(grade_id), subject_id: \(vc.subject_id)")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
