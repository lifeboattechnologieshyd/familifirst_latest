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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    self.navigationItem.hidesBackButton = true

        
        setupTableView()
        setupLottieAnimations()
        
        familybgVw.addCardShadow()
        eventsbgVw.addCardShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        familyLottieView?.play()
        eventsLottieView?.play()
    }
    
    private func setupTableView() {
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.separatorStyle = .none
        tblVw.backgroundColor = .clear
        
        tblVw.register(UINib(nibName: "UserCell", bundle: nil),
                       forCellReuseIdentifier: "UserCell")
        
        tblVw.register(UINib(nibName: "familyMemberCell", bundle: nil),
                       forCellReuseIdentifier: "familyMemberCell")
        
        tblVw.register(UINib(nibName: "AddMemberCell", bundle: nil),
                       forCellReuseIdentifier: "AddMemberCell")
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
}

extension FamiliVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: "UserCell",for: indexPath)
        case 1, 2, 3:
            return tableView.dequeueReusableCell(withIdentifier: "familyMemberCell",for: indexPath)
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddMemberCell",for: indexPath) as! AddMemberCell
            cell.onAddTapped = { [weak self] in
            self?.navigateToAddMemberVC()
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView,heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:           return 176
        case 1, 2, 3:     return 84
        default:          return 60
        }
    }
    
    func tableView(_ tableView: UITableView,
                   shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 else {
            return
        }
        
        navigateToMemberDetailsVC()
    }
}

extension FamiliVC {
    
    private func navigateToAddMemberVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "AddMemberVC"
        ) as? AddMemberVC else { return }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToMemberDetailsVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "MemberDetailsVC"
        ) as? MemberDetailsVC else { return }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
