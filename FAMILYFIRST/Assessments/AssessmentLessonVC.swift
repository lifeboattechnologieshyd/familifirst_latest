//
//  AssessmentLessonVC.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 11/10/25.
//

import UIKit

class AssessmentLessonVC: UIViewController {
    
    @IBOutlet weak var tblVw: UITableView!
    
    var subject_id = ""
    var grade_id = ""
    var lessons = [Lesson]()
    var selectedLessonIds: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getLessons()
    }
    
    private func setupTableView() {
        tblVw.register(UINib(nibName: "LessonCell", bundle: nil), forCellReuseIdentifier: "LessonCell")
        tblVw.delegate = self
        tblVw.dataSource = self
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickStartTest(_ sender: UIButton) {
        guard !selectedLessonIds.isEmpty else {
            self.showAlert(msg: "Please select at least one lesson to start the assessment")
            return
        }
        
        guard let vc = storyboard?.instantiateViewController(identifier: "AssessmentPreparationVC") as? AssessmentPreparationVC else {
            return
        }
        
        vc.grade_id = grade_id
        vc.subject_id = subject_id
        vc.selectedLessonIds = selectedLessonIds
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getLessons() {
        guard let userId = UserManager.shared.userId else {
            self.showAlert(msg: "User ID not found. Please login again.")
            return
        }
        
        guard !grade_id.isEmpty, !subject_id.isEmpty else {
            self.showAlert(msg: "Grade or Subject not selected. Please go back and select them.")
            return
        }
        
        showLoader()
        
        let lesson_url = "\(API.EDUTAIN_LESSONS)?grade=\(grade_id)&subject=\(subject_id)&user_id=\(userId)"
        
        NetworkManager.shared.request(urlString: lesson_url, method: .GET) { (result: Result<APIResponse<[Lesson]>, NetworkError>) in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        DispatchQueue.main.async {
                            self.lessons = data
                            self.tblVw.reloadData()
                            self.hideLoader()
                            
                            if data.isEmpty {
                                self.showAlert(msg: "No lessons available for this subject.")
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.hideLoader()
                            self.showAlert(msg: "No lessons available for this subject")
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.hideLoader()
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
    
    @objc func lessonButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < lessons.count else { return }
        
        lessons[index].selected.toggle()
        
        if lessons[index].selected {
            if !selectedLessonIds.contains(lessons[index].id) {
                selectedLessonIds.append(lessons[index].id)
            }
        } else {
            selectedLessonIds.removeAll { $0 == lessons[index].id }
        }
        
        tblVw.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
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

extension AssessmentLessonVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonCell", for: indexPath) as! LessonCell
        
        let lesson = lessons[indexPath.row]
        cell.lblName.text = "\(indexPath.row + 1). " + lesson.lessonName
        cell.btnSelect.tag = indexPath.row
        
        if lesson.selected {
            cell.btnSelect.setImage(UIImage(named: "lesson_selection"), for: .normal)
        } else {
            cell.btnSelect.setImage(UIImage(named: "add"), for: .normal)
        }
        
        cell.btnSelect.removeTarget(nil, action: nil, for: .allEvents)
        cell.btnSelect.addTarget(self, action: #selector(lessonButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lessonButtonTapped(UIButton().apply { $0.tag = indexPath.row })
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension UIButton {
    func apply(_ block: (UIButton) -> Void) -> UIButton {
        block(self)
        return self
    }
}
