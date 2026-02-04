//
//  FamiliViewcontroller.swift
//  FamilyFirst
//
//  Created by Lifeboat on 09/01/26.
//
import UIKit
import Lottie

class FamiliVC: UIViewController {
    
    @IBOutlet weak var familyVw: UIView!
    @IBOutlet weak var familybgVw: UIView!
    @IBOutlet weak var eventsVw: UIView!
    @IBOutlet weak var eventsbgVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    
    private var familyLottieView: LottieAnimationView?
    private var eventsLottieView: LottieAnimationView?
    
    private var familyMembers: [FamilyMember] = []
    private var selfMember: FamilyMember?
    
    enum TabSection {
        case family
        case events
    }
    
    private var currentSection: TabSection = .family
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        setupTableView()
        setupLottieAnimations()
        setupTapGestures()
        
        familybgVw.addCardShadow()
        eventsbgVw.addCardShadow()
        
        updateSelectionUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        familyLottieView?.play()
        eventsLottieView?.play()
        
        checkLoginStatus()
    }
    
    private func checkLoginStatus() {
        if UserManager.shared.isLoggedIn {
            fetchFamilyMembers()
        } else {
            showLoginVC()
        }
    }
    
    private func fetchFamilyMembers() {
        NetworkManager.shared.request(
            urlString: API.FAMILY_MASTER,
            method: .GET
        ) { [weak self] (result: Result<APIResponse<[FamilyMember]>, NetworkError>) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        self?.selfMember = data.first { $0.relationType?.lowercased() == "self" }
                        self?.familyMembers = data.filter { $0.relationType?.lowercased() != "self" }
                        self?.tblVw.reloadData()
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
    
    private func showLoginVC() {
        if presentedViewController != nil { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC else { return }
        
        let nav = UINavigationController(rootViewController: loginVC)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .fullScreen
        
        present(nav, animated: true)
    }
    
    private func setupTableView() {
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.separatorStyle = .none
        tblVw.backgroundColor = .clear
        
        tblVw.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        tblVw.register(UINib(nibName: "familyMemberCell", bundle: nil), forCellReuseIdentifier: "familyMemberCell")
        tblVw.register(UINib(nibName: "AddMemberCell", bundle: nil), forCellReuseIdentifier: "AddMemberCell")
        tblVw.register(UINib(nibName: "AddEventCell", bundle: nil), forCellReuseIdentifier: "AddEventCell")
        tblVw.register(UINib(nibName: "MonthCell", bundle: nil), forCellReuseIdentifier: "MonthCell")
    }
    
    private func setupLottieAnimations() {
        familyLottieView = LottieAnimationView(name: "family")
        setupLottie(familyLottieView, in: familyVw)
        
        eventsLottieView = LottieAnimationView(name: "calendar")
        setupLottie(eventsLottieView, in: eventsVw)
        
        familyLottieView?.play()
        eventsLottieView?.play()
    }
    
    private func setupLottie(_ animationView: LottieAnimationView?, in container: UIView) {
        guard let animationView = animationView else { return }
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.8
        
        container.subviews.forEach { $0.removeFromSuperview() }
        container.addSubview(animationView)
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
    }
    
    private func setupTapGestures() {
        let familyTap = UITapGestureRecognizer(target: self, action: #selector(familyTapped))
        familybgVw.isUserInteractionEnabled = true
        familybgVw.addGestureRecognizer(familyTap)
        
        let eventsTap = UITapGestureRecognizer(target: self, action: #selector(eventsTapped))
        eventsbgVw.isUserInteractionEnabled = true
        eventsbgVw.addGestureRecognizer(eventsTap)
    }
    
    @objc private func familyTapped() {
        guard currentSection != .family else { return }
        currentSection = .family
        updateSelectionUI()
        tblVw.reloadData()
    }
    
    @objc private func eventsTapped() {
        guard currentSection != .events else { return }
        currentSection = .events
        updateSelectionUI()
        tblVw.reloadData()
    }
    
    private func updateSelectionUI() {
        UIView.animate(withDuration: 0.3) {
            switch self.currentSection {
            case .family:
                self.familybgVw.alpha = 1.0
                self.familybgVw.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                self.eventsbgVw.alpha = 0.6
                self.eventsbgVw.transform = .identity
                
            case .events:
                self.eventsbgVw.alpha = 1.0
                self.eventsbgVw.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                self.familybgVw.alpha = 0.6
                self.familybgVw.transform = .identity
            }
        }
    }
}

extension FamiliVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentSection {
        case .family:
            return 1 + familyMembers.count + 1
        case .events:
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch currentSection {
        case .family:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
                if let member = selfMember {
                    cell.configure(with: member)
                }
                return cell
            } else if indexPath.row <= familyMembers.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "familyMemberCell", for: indexPath) as! familyMemberCell
                let member = familyMembers[indexPath.row - 1]
                cell.configure(with: member)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddMemberCell", for: indexPath) as! AddMemberCell
                cell.onAddTapped = { [weak self] in
                    self?.navigateToAddMemberVC()
                }
                return cell
            }
            
        case .events:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddEventCell", for: indexPath) as! AddEventCell
                cell.onAddEventTapped = { [weak self] in
                    self?.navigateToCreateEventVC()
                }
                return cell
            default:
                return tableView.dequeueReusableCell(withIdentifier: "MonthCell", for: indexPath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch currentSection {
        case .family:
            if indexPath.row == 0 {
                return 176
            } else if indexPath.row <= familyMembers.count {
                return 84
            } else {
                return 60
            }
        case .events:
            switch indexPath.row {
            case 0: return 50
            default: return 120
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch currentSection {
        case .family:
            if indexPath.row > 0 && indexPath.row <= familyMembers.count {
                let member = familyMembers[indexPath.row - 1]
                navigateToMemberDetailsVC(member: member)
            }
        case .events:
            break
        }
    }
}

extension FamiliVC {
    
    private func navigateToAddMemberVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "AddMemberVC") as? AddMemberVC else { return }
        vc.onMemberAdded = { [weak self] in
            self?.fetchFamilyMembers()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToMemberDetailsVC(member: FamilyMember) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "MemberDetailsVC") as? MemberDetailsVC else { return }
        vc.member = member
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToCreateEventVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "CreateEventVC") as? CreateEventVC else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
}
