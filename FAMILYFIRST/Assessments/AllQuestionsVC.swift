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
        
        // ✅ ADD THIS - Connect button programmatically
        backButton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
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
        print("🔴 BACK BUTTON TAPPED!")
        
        // Simple pop to root
        if let navController = self.navigationController {
            navController.popToRootViewController(animated: true)
        }
    }
    private func navigateToHomeVC() {
        print("🔴 navigateToHomeVC called")
        print("🔴 self.tabBarController: \(String(describing: self.tabBarController))")
        print("🔴 self.navigationController: \(String(describing: self.navigationController))")
        print("🔴 Navigation stack count: \(self.navigationController?.viewControllers.count ?? 0)")
        
        // Print all VCs in navigation stack
        self.navigationController?.viewControllers.forEach { vc in
            print("🔴 VC in stack: \(type(of: vc))")
        }
        
        // Method 1: Try popToRootViewController first
        if let navController = self.navigationController {
            print("🟢 Method 1: Using navigationController to pop")
            
            // Check if there's a tabBarController in the hierarchy
            if let tabBar = navController.tabBarController {
                print("🟢 Found tabBarController via navController")
                tabBar.selectedIndex = 0
            }
            
            navController.popToRootViewController(animated: true)
            return
        }
        
        // Method 2: If we have access to tabBarController directly
        if let tabBarController = self.tabBarController {
            print("🟢 Method 2: Using self.tabBarController")
            tabBarController.selectedIndex = 0
            if let navController = tabBarController.viewControllers?[0] as? UINavigationController {
                navController.popToRootViewController(animated: true)
            }
            return
        }
        
        // Method 3: Access through window's rootViewController
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            print("🟢 Method 3: Window rootViewController: \(type(of: window.rootViewController))")
            
            if let tabBarController = window.rootViewController as? UITabBarController {
                print("🟢 Found TabBarController as root")
                tabBarController.selectedIndex = 0
                if let navController = tabBarController.viewControllers?[0] as? UINavigationController {
                    navController.popToRootViewController(animated: true)
                }
                return
            }
            
            // Maybe TabBar is wrapped in NavigationController?
            if let navController = window.rootViewController as? UINavigationController,
               let tabBarController = navController.viewControllers.first as? UITabBarController {
                print("🟢 Found TabBarController inside NavController")
                tabBarController.selectedIndex = 0
                if let homeNav = tabBarController.viewControllers?[0] as? UINavigationController {
                    homeNav.popToRootViewController(animated: true)
                }
                return
            }
        }
        
        // Method 4: Final fallback - Create new TabBarController
        print("🟡 Method 4: Fallback - Creating new CustomTabBarController")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "CustomTabBarController") as? UITabBarController {
            tabBarVC.selectedIndex = 0
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = tabBarVC
                window.makeKeyAndVisible()
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
            }
        } else {
            print("🔴 Failed to instantiate CustomTabBarController!")
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
