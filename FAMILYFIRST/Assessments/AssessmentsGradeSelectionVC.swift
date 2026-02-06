//
//  AssessmentsGradeSelectionVC.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 11/10/25.
//

import UIKit

class AssessmentsGradeSelectionVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var completedAssessments: UIButton!
    @IBOutlet weak var colVw: UICollectionView!
    
    var grades = [GradeModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        getGrades()
        
        // Placeholder data for testing UI
        loadPlaceholderData()
    }
    
    private func setupCollectionView() {
        colVw.register(UINib(nibName: "GradeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "GradeCollectionCell")
        colVw.delegate = self
        colVw.dataSource = self
    }
    private func loadPlaceholderData() {
        // self.grades = []
        self.colVw.reloadData()
    }
    
    @IBAction func onClickCompleted(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(identifier: "PastAssessmentsVC") as! PastAssessmentsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    func getGrades() {
            // ✅ CHANGED: Check if userId exists before making API call
            guard let userId = UserManager.shared.userId else {
                print("❌ Error: userId not found in UserManager")
                self.showAlert(msg: "User ID not found. Please login again.")
                return
            }
            
            print("📱 Fetching grades for userId: \(userId)")
            
            showLoader()
            
            let urlString = "\(API.VOCABEE_GET_GRADES)?user_id=\(userId)"
            
            NetworkManager.shared.request(urlString: urlString, method: .GET) { (result: Result<APIResponse<[GradeModel]>, NetworkError>) in
                switch result {
                case .success(let info):
                    if info.success {
                        if let data = info.data {
                            self.grades = data.sorted {
                                if $0.numericGrade == $1.numericGrade {
                                    return $0.name < $1.name
                                }
                                return $0.numericGrade < $1.numericGrade
                            }
                            DispatchQueue.main.async {
                                self.colVw.reloadData()
                                self.hideLoader()
                                print("✅ Successfully loaded \(self.grades.count) grades")
                            }
                        } else {
                            // ✅ ADDED: Handle case where data is nil
                            DispatchQueue.main.async {
                                self.hideLoader()
                                print("⚠️ No grades data received")
                                self.showAlert(msg: "No grades available")
                            }
                        }
                    } else {
                        // ✅ ADDED: Handle API failure response
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
}

extension AssessmentsGradeSelectionVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.grades.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GradeCollectionCell", for: indexPath) as! GradeCollectionCell
            cell.lblGrade.text = self.grades[indexPath.row].name
            
            // Placeholder styling
            cell.lblGrade.backgroundColor = .white
            
            
            
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: (colVw.frame.size.width - 32) / 3, height: 32)
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            guard let vc = storyboard?.instantiateViewController(identifier: "AssessmentSubjectSelectionVC") as? AssessmentSubjectSelectionVC else {
                return
            }
            vc.grade_id = self.grades[indexPath.row].id
            
            // ✅ NOTE: Store selected grade in UserManager if needed
            // UserManager.shared.assessment_selected_grade = self.grades[indexPath.row]
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

