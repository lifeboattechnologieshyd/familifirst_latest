//
//  HomeVC.swift
//  FamilyFirst
//
//  Created by Lifeboat on 10/01/26.
//
import UIKit

class HomeVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        registerCells()
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
    
    private func navigateToNewsVC(with index: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsVC = storyboard.instantiateViewController(withIdentifier: "NewsVC") as! NewsVC
        if let navController = navigationController {
            navController.pushViewController(newsVC, animated: true)
        } else {
            newsVC.modalPresentationStyle = .fullScreen
            present(newsVC, animated: true)
        }
    }

    private func navigateToCalenderVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let calenderVC = storyboard.instantiateViewController(withIdentifier: "CalenderVC") as! CalenderVC
        if let navController = navigationController {
            navController.pushViewController(calenderVC, animated: true)
        } else {
            calenderVC.modalPresentationStyle = .fullScreen
            present(calenderVC, animated: true)
        }
    }
    
    private func navigateToCoursesVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CoursesVC") as! CoursesVC
        vc.initialTabIndex = 0
        if let navController = navigationController {
            navController.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    private func navigateToFeelsVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FeelsVC") as! FeelsVC
        if let navController = navigationController {
            navController.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    private func navigateToEdutainmentVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EdutainmentController") as! EdutainmentController
        if let navController = navigationController {
            navController.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
//    private func navigateToVocabBeesVC() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "VocabBeesViewController") as! VocabBeesViewController
//        if let navController = navigationController {
//            navController.pushViewController(vc, animated: true)
//        } else {
//            vc.modalPresentationStyle = .fullScreen
//            present(vc, animated: true)
//        }
//    }
    
    private func navigateToProsperityTipsVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProsperityTipsViewController") as! ProsperityTipsViewController
        if let navController = navigationController {
            navController.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    private func navigateToEdStoreVC() {
        let storyboard = UIStoryboard(name: "EdStore", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EdStoreViewController") as! EdStoreViewController
        if let navController = navigationController {
            navController.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    private func navigateToAssessmentsVC() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "AssessmentsViewController") as! AssessmentsViewController
            if let navController = navigationController {
                navController.pushViewController(vc, animated: true)
            } else {
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
        }
    
    private func navigateToOfflineEventsVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CoursesVC") as! CoursesVC
        vc.initialTabIndex = 3
        if let navController = navigationController {
            navController.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    private func navigateToParentingTipsVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ParentingTipsViewController") as! ParentingTipsViewController
        if let navController = navigationController {
            navController.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BannerCell", for: indexPath) as! BannerCell
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalenderCell", for: indexPath) as! CalenderCell
            cell.didTapViewAll = { [weak self] in
                self?.navigateToCalenderVC()
            }
            cell.didSelectCalenderItem = { [weak self] index in
                self?.navigateToCalenderVC()
            }
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IconsCell", for: indexPath) as! IconsCell
            
            cell.didTapCourses = { [weak self] in
                self?.navigateToCoursesVC()
            }
            
            cell.didTapFeels = { [weak self] in
                self?.navigateToFeelsVC()
            }
            
            cell.didTapEdutainment = { [weak self] in
                self?.navigateToEdutainmentVC()
            }
            
            cell.didTapProsperityTips = { [weak self] in
                self?.navigateToProsperityTipsVC()
            }
            
            cell.didTapStore = { [weak self] in
                self?.navigateToEdStoreVC()
            }
            
            cell.didTapOfflineEvents = { [weak self] in
                self?.navigateToOfflineEventsVC()
            }
            
            cell.didTapParentingTips = { [weak self] in
                self?.navigateToParentingTipsVC()
            }
            cell.didTapAssessments = { [weak self] in
                self?.navigateToAssessmentsVC()
            }
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShopCell", for: indexPath) as! ShopCell
            return cell
            
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return 114
        case 1: return 112
        case 2: return 712
        case 3: return 330
        default: return 0
        }
    }
}
