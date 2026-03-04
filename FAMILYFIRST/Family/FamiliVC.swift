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
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var eventsbgVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    
    private var familyLottieView: LottieAnimationView?
    private var eventsLottieView: LottieAnimationView?
    
    private var familyMembers: [FamilyMember] = []
    private var selfMember: FamilyMember?
    private var selfUserDetails: UserDetails?
    
    private var monthlyEvents: [MonthEventsGroup] = []
    private var allEvents: [Event] = []
    
    enum TabSection {
        case family
        case events
    }
    
    private var currentSection: TabSection = .family
    var initialSection: TabSection = .family
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProfileImageView()
        loadProfileImage()
        
        setupTableView()
        setupLottieAnimations()
        setupTapGestures()
        
        familybgVw.addCardShadow()
        eventsbgVw.addCardShadow()
        
        currentSection = initialSection
        updateSelectionUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = false
        
        familyLottieView?.play()
        eventsLottieView?.play()
        
        // 👈 Always reload profile image when view appears
        loadProfileImage()
        
        currentSection = initialSection
        updateSelectionUI()
        tblVw.reloadData()
        
        checkLoginStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    
    private func setupProfileImageView() {
        imgVw.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        imgVw.addGestureRecognizer(tapGesture)
    }
    
    private func loadProfileImage() {
        if let savedImage = UserManager.shared.profileImage {
            // First priority: UserDefaults saved image
            imgVw.image = savedImage
        } else if let imageUrl = selfUserDetails?.profileImage, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
            loadImageFromURL(url)
        } else if let imageUrl = selfMember?.profileImage, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
            loadImageFromURL(url)
        } else {
            // Default placeholder
            imgVw.image = UIImage(named: "Picture")
        }
    }
    
    private func loadImageFromURL(_ url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("❌ Error loading image: \(error.localizedDescription)")
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    // Only set if no local image saved in UserDefaults
                    if UserManager.shared.profileImage == nil {
                        self?.imgVw.image = image
                        print("✅ Profile image loaded from URL")
                    }
                }
            }
        }.resume()
    }
    
    private func updateProfileImage(_ image: UIImage) {
        UIView.transition(with: imgVw, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.imgVw.image = image
        }, completion: nil)
        
        UIView.animate(withDuration: 0.15, animations: {
            self.imgVw.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.imgVw.transform = .identity
            }
        }
    }
    
    @objc private func profileImageTapped() {
        showImagePickerOptions()
    }
    
    
    private func checkLoginStatus() {
        if UserManager.shared.isLoggedIn {
            fetchFamilyMembers()
            fetchUserDetails()
            if currentSection == .events {
                fetchEvents()
            }
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
                        
                        if let selfMember = self?.selfMember, let userId = selfMember.effectiveId {
                            UserManager.shared.saveUserId(userId)
                        }
                        
                        self?.loadProfileImage()
                        self?.tblVw.reloadData()
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
    
    private func fetchUserDetails() {
        let mobile = UserManager.shared.mobile
        let email = UserManager.shared.email
        
        var urlString = API.USER_DETAILS
        
        if !mobile.isEmpty {
            urlString += "?mobile=\(mobile)"
        } else if !email.isEmpty {
            urlString += "?email=\(email)"
        } else if let userId = UserManager.shared.userId {
            urlString += "?id=\(userId)"
        } else {
            return
        }
        
        NetworkManager.shared.request(
            urlString: urlString,
            method: .GET
        ) { [weak self] (result: Result<APIResponse<UserDetails>, NetworkError>) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        self?.selfUserDetails = data
                        
                        // 👈 Reload profile image after fetching user details
                        self?.loadProfileImage()
                        self?.tblVw.reloadData()
                    }
                case .failure(let error):
                    print("Error fetching user details: \(error)")
                }
            }
        }
    }
    
    private func fetchEvents() {
        guard let userId = UserManager.shared.userId else { return }
        
        let urlString = "\(API.GET_EVENTS)?event_users=\(userId)"
        
        NetworkManager.shared.request(
            urlString: urlString,
            method: .GET
        ) { [weak self] (result: Result<APIResponse<[Event]>, NetworkError>) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let events = response.data {
                        self?.allEvents = events
                        self?.groupEventsByMonth(events)
                        self?.tblVw.reloadData()
                    }
                case .failure(let error):
                    print("Error fetching events: \(error)")
                }
            }
        }
    }
    
    private func groupEventsByMonth(_ events: [Event]) {
        var grouped: [String: [Event]] = [:]
        var sortDates: [String: Date] = [:]
        var monthNames: [String: String] = [:]
        
        for event in events {
            let key = event.monthYearKey
            if grouped[key] == nil {
                grouped[key] = []
            }
            grouped[key]?.append(event)
            
            if sortDates[key] == nil, let date = event.eventDate {
                sortDates[key] = date
            }
            
            if monthNames[key] == nil {
                monthNames[key] = event.monthOnlyKey
            }
        }
        
        monthlyEvents = grouped.map { (key, events) in
            MonthEventsGroup(
                monthYear: key,
                monthOnly: monthNames[key] ?? key,
                events: events.sorted { ($0.eventDate ?? Date()) < ($1.eventDate ?? Date()) },
                sortOrder: sortDates[key] ?? Date()
            )
        }.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    private func getEventsForMember(_ memberId: String) -> [Event] {
        return allEvents.filter { event in
            event.eventUsers.contains(memberId)
        }.sorted { ($0.eventDate ?? Date()) < ($1.eventDate ?? Date()) }
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
        tblVw.register(UINib(nibName: "AddCell", bundle: nil), forCellReuseIdentifier: "AddCell")
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
        initialSection = .family
        updateSelectionUI()
        tblVw.reloadData()
    }
    
    @objc private func eventsTapped() {
        guard currentSection != .events else { return }
        currentSection = .events
        initialSection = .events
        updateSelectionUI()
        fetchEvents()
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
    
    
    private func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        toastLabel.text = "  ✓ \(message)  "
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 20
        toastLabel.clipsToBounds = true
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(toastLabel)
        
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            toastLabel.heightAnchor.constraint(equalToConstant: 40),
            toastLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 150)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, options: [], animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}



extension FamiliVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch currentSection {
        case .family:
            return 1
        case .events:
            return 1 + monthlyEvents.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentSection {
        case .family:
            return 1 + familyMembers.count + 1
        case .events:
            if section == 0 {
                return 1
            } else {
                let monthIndex = section - 1
                return monthlyEvents[monthIndex].events.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch currentSection {
        case .family:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
                
                if let userDetails = selfUserDetails {
                    cell.configureWithUserDetails(userDetails)
                } else if let member = selfMember {
                    cell.configure(with: member)
                }
                
                // Handle Edit Profile tap
                cell.onEditTapped = { [weak self] in
                    self?.navigateToProfileEditVC()
                }
                
                // Handle Edit Picture tap
                cell.onEditPictureTapped = { [weak self] in
                    self?.showImagePickerOptions()
                }
                
                // Handle copy button tap
                cell.onCopyTapped = { [weak self] in
                    self?.showToast(message: "Referral code copied!")
                }
                
                // Handle share button tap
                cell.onShareTapped = { [weak self] in
                    self?.shareReferralCode()
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
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddCell", for: indexPath) as! AddCell
                cell.onAddEventTapped = { [weak self] in
                    self?.navigateToCreateEventVC()
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MonthCell", for: indexPath) as! MonthCell
                let monthIndex = indexPath.section - 1
                let event = monthlyEvents[monthIndex].events[indexPath.row]
                cell.configure(with: event)
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch currentSection {
        case .family:
            return nil
        case .events:
            if section == 0 {
                return nil
            } else {
                let headerView = UIView()
                headerView.backgroundColor = .clear
                
                let lineColor = UIColor(hex: "#CDE1D7") ?? .lightGray
                
                let leftLine = UIView()
                leftLine.backgroundColor = lineColor
                leftLine.translatesAutoresizingMaskIntoConstraints = false
                
                let rightLine = UIView()
                rightLine.backgroundColor = lineColor
                rightLine.translatesAutoresizingMaskIntoConstraints = false
                
                let monthLabel = UILabel()
                monthLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
                monthLabel.textColor = .darkGray
                monthLabel.textAlignment = .center
                monthLabel.translatesAutoresizingMaskIntoConstraints = false
                
                let monthIndex = section - 1
                monthLabel.text = monthlyEvents[monthIndex].monthOnly
                
                headerView.addSubview(leftLine)
                headerView.addSubview(monthLabel)
                headerView.addSubview(rightLine)
                
                NSLayoutConstraint.activate([
                    leftLine.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 0),
                    leftLine.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                    leftLine.heightAnchor.constraint(equalToConstant: 1),
                    leftLine.trailingAnchor.constraint(equalTo: monthLabel.leadingAnchor, constant: -12),
                    
                    monthLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
                    monthLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                    
                    rightLine.leadingAnchor.constraint(equalTo: monthLabel.trailingAnchor, constant: 12),
                    rightLine.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 0),
                    rightLine.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                    rightLine.heightAnchor.constraint(equalToConstant: 1)
                ])
                
                return headerView
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch currentSection {
        case .family:
            return 0
        case .events:
            return section == 0 ? 0 : 40
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch currentSection {
        case .family:
            if indexPath.row == 0 {
                return 166
            } else if indexPath.row <= familyMembers.count {
                return 84
            } else {
                return 60
            }
        case .events:
            return indexPath.section == 0 ? 50 : 76
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
            if indexPath.section > 0 {
                let monthIndex = indexPath.section - 1
                let event = monthlyEvents[monthIndex].events[indexPath.row]
                print("Selected event: \(event.eventName)")
            }
        }
    }
}



extension FamiliVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showImagePickerOptions() {
        let alert = UIAlertController(title: "Change Profile Picture", message: "Choose an option", preferredStyle: .actionSheet)
        
        // Camera option
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "📷 Take Photo", style: .default) { [weak self] _ in
                self?.openImagePicker(sourceType: .camera)
            })
        }
        
        // Photo Library option
        alert.addAction(UIAlertAction(title: "🖼️ Choose from Gallery", style: .default) { [weak self] _ in
            self?.openImagePicker(sourceType: .photoLibrary)
        })
        
        // Remove photo option (only show if image exists)
        if UserManager.shared.hasProfileImage {
            alert.addAction(UIAlertAction(title: "🗑️ Remove Photo", style: .destructive) { [weak self] _ in
                UserManager.shared.removeProfileImage()
                
                // 👈 Update imgVw with placeholder
                self?.imgVw.image = UIImage(named: "Picture")
                
                // 👈 Reload table to update UserCell also
                self?.tblVw.reloadData()
                
                self?.showToast(message: "Profile picture removed")
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    // 👈 Handle image selection
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        // Get edited or original image
        let image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
        
        if let selectedImage = image {
            // 👈 Save to UserDefaults
            UserManager.shared.saveProfileImage(selectedImage)
            
            // 👈 Update imgVw with animation
            updateProfileImage(selectedImage)
            
            // 👈 Reload table to update UserCell also
            tblVw.reloadData()
            
            // Show success message
            showToast(message: "Profile picture updated!")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}



extension FamiliVC {
    
    private func navigateToAddMemberVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "AddMemberVC") as? AddMemberVC else { return }
        vc.onMemberAdded = { [weak self] in
            self?.fetchFamilyMembers()
        }
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToMemberDetailsVC(member: FamilyMember) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "MemberDetailsVC") as? MemberDetailsVC else { return }
        
        vc.member = member
        
        if let memberId = member.effectiveId {
            vc.memberEvents = getEventsForMember(memberId)
        }
        
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToCreateEventVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "CreateEventVC") as? CreateEventVC else { return }
        vc.familyMembers = self.familyMembers
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToProfileEditVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "ProfileEditVC") as? ProfileEditVC else { return }
        
        vc.onProfileUpdated = { [weak self] in
            self?.fetchFamilyMembers()
            self?.fetchUserDetails()
            self?.loadProfileImage() // 👈 Reload image after profile update
        }
        
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func shareReferralCode() {
        guard let code = selfUserDetails?.referralCode, !code.isEmpty else {
            showToast(message: "No referral code available")
            return
        }
        
        let message = "Join FamilyFirst using my referral code: \(code)"
        let activityVC = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        present(activityVC, animated: true)
    }
}
