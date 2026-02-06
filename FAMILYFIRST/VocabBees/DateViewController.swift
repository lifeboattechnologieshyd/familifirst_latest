//
//  DateViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 22/10/25.
//

import UIKit

class DateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var topbarView: UIView!
    @IBOutlet weak var tblVw: UITableView!
    
    var dates = [VocabeeDate]()
    var selectedGradeId: String = ""
    var selectedGradeName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topbarView.addBottomShadow()
        
        getDates()
        
        tblVw.register(UINib(nibName: "VocabBeeDateCell", bundle: nil), forCellReuseIdentifier: "VocabBeeDateCell")
        
        tblVw.dataSource = self
        tblVw.delegate = self
    }
    
    func getDates() {
        showLoader()
        let url = API.VOCABEE_WORDS_HISTORY + "?grade=\(selectedGradeId)"
        
        NetworkManager.shared.request(urlString: url, method: .GET) { (result: Result<APIResponse<[VocabeeDate]>, NetworkError>) in
            DispatchQueue.main.async {
                self.hideLoader()
                switch result {
                case .success(let info):
                    if info.success {
                        if let data = info.data {
                            self.dates = data
                        }
                        self.tblVw.reloadData()
                    } else {
                        print(info.description ?? "No description")
                        if self.dates.isEmpty {
                            self.showNoDatesAlert()
                        }
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
    
    func showNoDatesAlert() {
        let alert = UIAlertController(
            title: "No History",
            message: "No daily words found for this grade",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VocabBeeDateCell") as! VocabBeeDateCell
        cell.setup(item: self.dates[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDate = self.dates[indexPath.row]
        
        let storyboard = UIStoryboard(name: "VocabBees", bundle: nil)
        if let nextVC = storyboard.instantiateViewController(withIdentifier: "DailyChallengeViewController") as? DailyChallengeViewController {
            nextVC.selectedGradeId = self.selectedGradeId
            nextVC.selectedGradeName = self.selectedGradeName
            nextVC.selectedDate = selectedDate
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    @IBAction func BackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "VocabBees", bundle: nil)
        if let gradeVC = storyboard.instantiateViewController(withIdentifier: "DailyChallengeViewController") as? DailyChallengeViewController {
            gradeVC.selectedGradeId = self.selectedGradeId
            gradeVC.selectedGradeName = self.selectedGradeName
            self.navigationController?.pushViewController(gradeVC, animated: true)
        }
    }
}
