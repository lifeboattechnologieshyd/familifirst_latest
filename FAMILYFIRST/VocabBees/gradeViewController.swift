//
//  gradeViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 20/10/25.
//

import UIKit

class gradeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var topbarView: UIView!
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var colVw: UICollectionView!
    
    var grades = [GradeModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topbarView.addBottomShadow()
        getGrades()
        
        colVw.register(UINib(nibName: "gradeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "gradeCollectionViewCell")
        
        colVw.delegate = self
        colVw.dataSource = self
    }
    
    func getGrades() {
        showLoader()
        NetworkManager.shared.request(urlString: API.VOCABEE_GET_GRADES, method: .GET) { (result: Result<APIResponse<[GradeModel]>, NetworkError>) in
            DispatchQueue.main.async {
                self.hideLoader()
                switch result {
                case .success(let info):
                    if info.success {
                        if let data = info.data {
                            let sortedGrades = data.sorted { $0.numericGrade < $1.numericGrade }
                            self.grades = sortedGrades
                            self.colVw.reloadData()
                        }
                    } else {
                        print(info.description ?? "No description")
                    }
                case .failure(let error):
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
