import UIKit

class PastAssessmentsVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tblVw: UITableView!
    
    var assessments = [EdutainResultData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getHistory()
    }
    
    private func setupTableView() {
        tblVw.register(UINib(nibName: "AssessmentCardCell", bundle: nil), forCellReuseIdentifier: "AssessmentCardCell")
        tblVw.delegate = self
        tblVw.dataSource = self
    }
    
    private func navigateToAllQuestions(ass_id: String) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "AllQuestionsVC") as! AllQuestionsVC
        vc.assessmentId = ass_id
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getHistory() {
        showLoader()
        let url = API.EDUTAIN_MY_RESULTS
        
        NetworkManager.shared.request(urlString: url, method: .GET) { (result: Result<APIResponse<[EdutainResultData]>, NetworkError>) in
            self.hideLoader()
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        DispatchQueue.main.async {
                            self.assessments = data
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

extension PastAssessmentsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assessments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssessmentCardCell") as! AssessmentCardCell
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.btnSeeAns.tag = indexPath.row
        cell.onSelectAns = { index in
            self.navigateToAllQuestions(ass_id: self.assessments[index].assessment_id)
        }
        cell.setupEdutain(assessment: self.assessments[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 181
    }
}
