//
//  CalenderVC.swift
//  FamilyFirst
//
//  Created by Lifeboat on 13/01/26.
//
import UIKit

class HomeVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgVw: UIImageView!
    
    private var upcomingEvents: [Event] = []
    private var todaysCalendarData: CalendarData?
    private var products: [Product] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        registerCells()
        fetchUserIdAndLoadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = false
        imgVw.image = UserManager.shared.profileImage ?? UIImage(named: "Picture")
        
        if UserManager.shared.isLoggedIn && !upcomingEvents.isEmpty { return }
        fetchUserIdAndLoadData()
    }
    
    private func fetchUserIdAndLoadData() {
        if let userId = UserManager.shared.userId, !userId.isEmpty {
            fetchUpcomingEvents()
            fetchCalendarData()
            fetchProducts()
        } else {
            NetworkManager.shared.request(urlString: API.FAMILY_MASTER, method: .GET) { [weak self] (result: Result<APIResponse<[FamilyMember]>, NetworkError>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        if response.success, let data = response.data {
                            if let selfMember = data.first(where: { $0.relationType?.lowercased() == "self" }),
                               let userId = selfMember.effectiveId {
                                UserManager.shared.saveUserId(userId)
                                self?.fetchUpcomingEvents()
                                self?.fetchCalendarData()
                                self?.fetchProducts()
                            }
                        }
                    case .failure(let error):
                        print("Error fetching family members: \(error)")
                    }
                }
            }
        }
    }
    
    private func fetchCalendarData() {
        NetworkManager.shared.request(urlString: API.BROADCAST_CALENDAR, method: .GET) { [weak self] (result: Result<APIResponse<[CalendarData]>, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let calendarList = response.data, !calendarList.isEmpty {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd-MM-yyyy"
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                        let todayString = dateFormatter.string(from: Date())
                        
                        self?.todaysCalendarData = calendarList.first { $0.date == todayString } ?? calendarList.first
                    } else {
                        self?.todaysCalendarData = nil
                    }
                    self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                case .failure(let error):
                    print("Error fetching calendar: \(error)")
                }
            }
        }
    }
    
    private func fetchUpcomingEvents() {
        guard let userId = UserManager.shared.userId else { return }
        let urlString = "\(API.GET_EVENTS)?event_users=\(userId)"
        
        NetworkManager.shared.request(urlString: urlString, method: .GET) { [weak self] (result: Result<APIResponse<[Event]>, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let events = response.data {
                        let filteredEvents = events
                            .filter { ($0.eventDate ?? Date()) >= Date() }
                            .sorted { ($0.eventDate ?? Date()) < ($1.eventDate ?? Date()) }
                        self?.upcomingEvents = Array(filteredEvents.prefix(7))
                    } else {
                        self?.upcomingEvents = []
                    }
                    self?.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
                case .failure(let error):
                    print("Error fetching events: \(error)")
                    self?.upcomingEvents = []
                    self?.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
                }
            }
        }
    }
    
    private func fetchProducts() {
        NetworkManager.shared.request(urlString: API.ONLINE_STORE_PRODUCTS, method: .GET, parameters: ["page": 1, "limit": 10]) { [weak self] (result: Result<APIResponse<[Product]>, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let products = response.data, !products.isEmpty {
                        self?.products = products
                        self?.tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .none)
                    }
                case .failure(let error):
                    print("Error fetching products: \(error)")
                }
            }
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }

    private func registerCells() {
        tableView.register(UINib(nibName: "BannerCell", bundle: nil), forCellReuseIdentifier: "BannerCell")
        tableView.register(UINib(nibName: "CalenderCell", bundle: nil), forCellReuseIdentifier: "CalenderCell")
        tableView.register(UINib(nibName: "IconsCell", bundle: nil), forCellReuseIdentifier: "IconsCell")
        tableView.register(UINib(nibName: "ShopCell", bundle: nil), forCellReuseIdentifier: "ShopCell")
    }
    
    private func navigateToCalenderVC() {
        if let tabBarController = self.tabBarController {
            for (index, viewController) in (tabBarController.viewControllers ?? []).enumerated() {
                if let navController = viewController as? UINavigationController,
                   let familiVC = navController.viewControllers.first as? FamiliVC {
                    familiVC.initialSection = .events
                    tabBarController.selectedIndex = index
                    navController.popToRootViewController(animated: false)
                    return
                }
            }
        }
    }
    
    private func navigateToCoursesVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CoursesVC") as! CoursesVC
        vc.initialTabIndex = 0
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToFeelsVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FeelsVC") as! FeelsVC
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToEdutainmentVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EdutainmentController") as! EdutainmentController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToProsperityTipsVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProsperityTipsViewController") as! ProsperityTipsViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToEdStoreVC() {
        let storyboard = UIStoryboard(name: "EdStore", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EdStoreViewController") as! EdStoreViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToCheckoutVC(with product: Product) {
        let storyboard = UIStoryboard(name: "EdStore", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CheckOutViewController") as! CheckOutViewController
        vc.selectedProduct = product
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToAssessmentsVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AssessmentsGradeSelectionVC") as! AssessmentsGradeSelectionVC
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToParentingTipsVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ParentingTipsViewController") as! ParentingTipsViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToFamilyVC() {
        if let tabBarController = self.tabBarController {
            for (index, viewController) in (tabBarController.viewControllers ?? []).enumerated() {
                if let navController = viewController as? UINavigationController,
                   let familiVC = navController.viewControllers.first as? FamiliVC {
                    familiVC.initialSection = .family
                    tabBarController.selectedIndex = index
                    navController.popToRootViewController(animated: false)
                    return
                }
            }
        }
    }
    
    private func navigateToVocabBeeVC() {
        let storyboard = UIStoryboard(name: "VocabBees", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "VocabBeesViewController") as! VocabBeesViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToEventsVC() {
        if let tabBarController = self.tabBarController {
            for (index, viewController) in (tabBarController.viewControllers ?? []).enumerated() {
                if let navController = viewController as? UINavigationController,
                   let familiVC = navController.viewControllers.first as? FamiliVC {
                    familiVC.initialSection = .events
                    tabBarController.selectedIndex = index
                    navController.popToRootViewController(animated: false)
                    return
                }
            }
        }
    }
    
    private func showLogoutAlert() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in self?.performLogout() })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    private func performLogout() {
        UserManager.shared.logout()
        navigateToLogin()
    }

    private func navigateToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UINavigationController(rootViewController: loginVC)
            window.makeKeyAndVisible()
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 4 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BannerCell", for: indexPath) as! BannerCell
            cell.configure(with: todaysCalendarData)
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalenderCell", for: indexPath) as! CalenderCell
            cell.events = upcomingEvents
            cell.didTapViewAll = { [weak self] in self?.navigateToCalenderVC() }
            cell.didSelectCalenderItem = { [weak self] _ in self?.navigateToCalenderVC() }
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IconsCell", for: indexPath) as! IconsCell
            cell.didTapVocabBee = { [weak self] in self?.navigateToVocabBeeVC() }
            cell.didTapEdStore = { [weak self] in self?.navigateToEdStoreVC() }
            cell.didTapCourses = { [weak self] in self?.navigateToCoursesVC() }
            cell.didTapFeels = { [weak self] in self?.navigateToFeelsVC() }
            cell.didTapEdutainment = { [weak self] in self?.navigateToEdutainmentVC() }
            cell.didTapProsperityTips = { [weak self] in self?.navigateToProsperityTipsVC() }
            cell.didTapParentingTips = { [weak self] in self?.navigateToParentingTipsVC() }
            cell.didTapAssessments = { [weak self] in self?.navigateToAssessmentsVC() }
            cell.didTapMyFamily = { [weak self] in self?.navigateToFamilyVC() }
            cell.didTapMyEvents = { [weak self] in self?.navigateToEventsVC() }
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShopCell", for: indexPath) as! ShopCell
            cell.products = products
            cell.didTapLogout = { [weak self] in self?.showLogoutAlert() }
            cell.didTapViewAll = { [weak self] in self?.navigateToEdStoreVC() }
            cell.didSelectProduct = { [weak self] product in self?.navigateToCheckoutVC(with: product) }
            return cell
            
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return 96
        case 1: return 112
        case 2: return 712
        case 3: return 330
        default: return 0
        }
    }
}
