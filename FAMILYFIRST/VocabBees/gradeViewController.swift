//
//  gradeViewController.swift
//  FamilyFirst
//
//  Created by Lifeboat on 20/10/25.
//

import UIKit

class gradeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var topbarView: UIView!
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var colVw: UICollectionView!
    
    // MARK: - Properties
    var grades = [GradeModel]()
    
    // MARK: - Pagination Properties
    var currentPage: Int = 1
    var totalGrades: Int = 0
    var isLoading: Bool = false
    let pageSize: Int = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topbarView.addBottomShadow()
        
        colVw.register(UINib(nibName: "gradeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "gradeCollectionViewCell")
        
        colVw.delegate = self
        colVw.dataSource = self
        
        getGrades()
    }
    
    // MARK: - Fetch Grades with Pagination
    
    func getGrades() {
        guard !isLoading else { return }
        
        isLoading = true
        
        // Show loader only for first page
        if currentPage == 1 && grades.isEmpty {
            showLoader()
        }
        
        // API URL with pagination (page & page_size)
        let url = "\(API.VOCABEE_GET_GRADES)?page=\(currentPage)&page_size=\(pageSize)"
        
        print("🔗 Fetching grades: Page \(currentPage), PageSize \(pageSize)")
        
        NetworkManager.shared.request(urlString: url, method: .GET) { (result: Result<APIResponse<[GradeModel]>, NetworkError>) in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let info):
                    if info.success {
                        if let data = info.data {
                            // Store total count
                            if let total = info.total {
                                self.totalGrades = total
                            }
                            
                            // Append new grades
                            self.grades.append(contentsOf: data)
                            
                            // Remove duplicates
                            self.grades = self.removeDuplicates(from: self.grades)
                            
                            // Sort by numeric grade
                            self.grades.sort { $0.numericGrade < $1.numericGrade }
                            
                            print("✅ Page \(self.currentPage): Loaded \(self.grades.count) of \(self.totalGrades) grades")
                            
                            // Check if more pages needed
                            if self.grades.count < self.totalGrades && data.count > 0 {
                                // More grades available - fetch next page
                                self.currentPage += 1
                                self.getGrades()  // Auto fetch next page
                            } else {
                                // All grades loaded
                                self.hideLoader()
                                self.colVw.reloadData()
                                
                                print("✅ All \(self.grades.count) grades loaded!")
                            }
                        }
                    } else {
                        self.hideLoader()
                        print(info.description ?? "No description")
                    }
                    
                case .failure(let error):
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
    
    // MARK: - Helper Method
    
    func removeDuplicates(from grades: [GradeModel]) -> [GradeModel] {
        var seen = Set<String>()
        return grades.filter { grade in
            if seen.contains(grade.id) {
                return false
            } else {
                seen.insert(grade.id)
                return true
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
    
    // MARK: - UICollectionView DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return grades.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gradeCollectionViewCell", for: indexPath) as! gradeCollectionViewCell
        cell.clsLabel.text = grades[indexPath.row].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (colVw.frame.size.width) / 2, height: 54)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedGrade = grades[indexPath.row]
        let selectedMode = UserDefaults.standard.string(forKey: "vocabBee_selected_mode") ?? "PRACTICE"
        
        let storyboard = UIStoryboard(name: "VocabBees", bundle: nil)
        
        if selectedMode == "DAILY" {
            if let nextVC = storyboard.instantiateViewController(withIdentifier: "DateViewController") as? DateViewController {
                nextVC.selectedGradeId = selectedGrade.id
                nextVC.selectedGradeName = selectedGrade.name
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        } else {
            if let nextVC = storyboard.instantiateViewController(withIdentifier: "PracticeGameController") as? PracticeGameController {
                nextVC.selectedGradeId = selectedGrade.id
                nextVC.selectedGradeName = selectedGrade.name
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }
    }
    
    @IBAction func BackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
