//
//  AllQuestionsVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 11/11/25.
//

import UIKit

class AllQuestionsVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    
    var questions = [AssessmentQuestionHistoryDetails]()
    var assessmentId: String!
    var is_back_to_root = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getHistoryQuestions()
    }
    
    private func setupTableView() {
        registerCells()
        tblVw.rowHeight = UITableView.automaticDimension
        tblVw.estimatedRowHeight = 300
        tblVw.delegate = self
        tblVw.dataSource = self
    }

    private func registerCells() {
        tblVw.register(UINib(nibName: "QuestionOneCell", bundle: nil), forCellReuseIdentifier: "QuestionOneCell")
        tblVw.register(UINib(nibName: "QuestionTwoCell", bundle: nil), forCellReuseIdentifier: "QuestionTwoCell")
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        if is_back_to_root {
            navigationController?.popToRootViewController(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func getHistoryQuestions() {
        showLoader()
        let url = "\(API.EDUTAIN_MY_ANSWERS)?assessment=\(assessmentId!)"
        
        NetworkManager.shared.request(urlString: url, method: .GET) { (result: Result<APIResponse<[AssessmentQuestionHistoryDetails]>, NetworkError>) in
            self.hideLoader()
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        DispatchQueue.main.async {
                            self.questions = data
                            self.tblVw.reloadData()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(msg: info.description)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
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

extension AllQuestionsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionOneCell") as! QuestionOneCell
        cell.setup(row: indexPath.row, question: self.questions[indexPath.row], ques: self.questions.count)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
