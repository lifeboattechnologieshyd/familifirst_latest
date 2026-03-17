//
//  EdutainmentVC.swift
//  FamilyFirst
//
//  Created by Lifeboat on 14/01/26.
//

import UIKit

class EdutainmentVC: UIViewController {
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var searchTf: UITextField!
    @IBOutlet weak var micBtn: UIButton!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var goBtn: UIButton!
    @IBOutlet weak var videonoTf: UITextField!
    
    var allFeed = [Feed]()
    var diyFeed = [Feed]()
    var storiesFeed = [Feed]()
    var currentFeed = [Feed]()
    var searchResults = [Feed]()
    var isSearchActive = false
    var searchDebounceTimer: Timer?
    
    // f_category constants
    let DIY_F_CATEGORY = "Diy"
    let STORIES_F_CATEGORY = "Stories"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentControl()
        setupTextFields()
        setupTableView()
        segmentController.selectedSegmentIndex = 0
        getAllFeed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imgVw.image = UserManager.shared.profileImage ?? UIImage(named: "Picture")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applySegmentCornerRadius()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applySegmentCornerRadius()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAllVideos()
    }
    
    func setupSegmentControl() {
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.lexend(.regular, size: 16),
            .foregroundColor: UIColor.gray
        ]
        segmentController.setTitleTextAttributes(normalAttributes, for: .normal)

        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.lexend(.semiBold, size: 16),
            .foregroundColor: UIColor.white
        ]
        segmentController.setTitleTextAttributes(selectedAttributes, for: .selected)
        segmentController.backgroundColor = UIColor.white
        
        DispatchQueue.main.async {
            self.applySegmentCornerRadius()
        }
    }
    
    func applySegmentCornerRadius() {
        guard segmentController.frame.height > 0 else { return }
        let cornerRadius = segmentController.frame.height / 2
        segmentController.layer.cornerRadius = cornerRadius
        segmentController.layer.masksToBounds = true
        segmentController.clipsToBounds = true
    }
    
    func setupTextFields() {
        searchTf.delegate = self
        searchTf.returnKeyType = .search
        searchTf.addTarget(self, action: #selector(searchTextFieldDidChange(_:)), for: .editingChanged)
        videonoTf.delegate = self
        videonoTf.keyboardType = .numberPad
        videonoTf.addTarget(self, action: #selector(videoNumberTextFieldDidChange(_:)), for: .editingChanged)
        addDoneButtonToKeyboard()
    }
    
    func addDoneButtonToKeyboard() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexSpace, doneButton]
        videonoTf.inputAccessoryView = toolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupTableView() {
        tblVw.register(UINib(nibName: "EdutainCell", bundle: nil), forCellReuseIdentifier: "EdutainCell")
        tblVw.register(UINib(nibName: "StoriesCell", bundle: nil), forCellReuseIdentifier: "StoriesCell")
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.keyboardDismissMode = .onDrag
    }
    
    func navigateToComments(feed: Feed, cellType: FeedCellType) {
        stopAllVideos()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "CommentsVC") as? CommentsVC else { return }
        vc.feed = feed
        vc.cellType = cellType
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func stopAllVideos() {
        for cell in tblVw.visibleCells {
            if let storiesCell = cell as? StoriesCell {
                storiesCell.stopVideo()
            }
        }
    }
    
    func stopInvisibleVideos() {
        guard segmentController.selectedSegmentIndex == 1 else { return }
        
        for cell in tblVw.visibleCells {
            guard let storiesCell = cell as? StoriesCell,
                  let indexPath = tblVw.indexPath(for: storiesCell) else { continue }
            
            let cellRect = tblVw.rectForRow(at: indexPath)
            let visibleRect = CGRect(x: tblVw.contentOffset.x, y: tblVw.contentOffset.y, width: tblVw.bounds.width, height: tblVw.bounds.height)
            let intersection = cellRect.intersection(visibleRect)
            let visiblePercentage = intersection.height / cellRect.height
            
            if visiblePercentage < 0.5 {
                storiesCell.stopVideo()
            }
        }
    }
    
    // MARK: - Helper to check f_category
    func feedMatchesFCategory(_ feed: Feed, fCategory: String) -> Bool {
        guard let feedFCategory = feed.fCategory else { return false }
        return feedFCategory.lowercased() == fCategory.lowercased()
    }
    
    func getCurrentFCategory() -> String {
        return segmentController.selectedSegmentIndex == 0 ? DIY_F_CATEGORY : STORIES_F_CATEGORY
    }
    
    func getAllFeed() {
        showLoader()
        let url = API.EDUTAIN_FEED
        
        NetworkManager.shared.request(urlString: url, method: .GET) { [weak self] (result: Result<APIResponse<[Feed]>, NetworkError>) in
            guard let self = self else { return }
            self.hideLoader()
            
            switch result {
            case .success(let info):
                if info.success, let data = info.data {
                    self.allFeed = data
                    DispatchQueue.main.async {
                        self.filterAndSetData()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(msg: info.description)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showAlert(msg: error.localizedDescription)
                }
            }
        }
    }
    
    func filterAndSetData() {
        diyFeed = allFeed.filter { feed in
            return feedMatchesFCategory(feed, fCategory: DIY_F_CATEGORY)
        }
        
        storiesFeed = allFeed.filter { feed in
            return feedMatchesFCategory(feed, fCategory: STORIES_F_CATEGORY)
        }
        
        currentFeed = segmentController.selectedSegmentIndex == 0 ? diyFeed : storiesFeed
        tblVw.reloadData()
    }
    
    @IBAction func onChangeSegment(_ sender: UISegmentedControl) {
        clearSearch()
        stopAllVideos()
        currentFeed = sender.selectedSegmentIndex == 0 ? diyFeed : storiesFeed
        tblVw.reloadData()
        
        if !currentFeed.isEmpty {
            tblVw.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
    
    @IBAction func onClickGo(_ sender: UIButton) {
        dismissKeyboard()
        
        guard let serialText = videonoTf.text?.trimmingCharacters(in: .whitespaces), !serialText.isEmpty else {
            showAlert(msg: "Please enter a video number")
            return
        }
        
        guard let serialNumber = Int(serialText) else {
            showAlert(msg: "Please enter a valid number")
            return
        }
        
        searchTf.text = ""
        searchDebounceTimer?.invalidate()
        searchBySerialNumber(serialNumber: serialNumber)
    }
    
    func clearSearch() {
        searchDebounceTimer?.invalidate()
        searchTf.text = ""
        videonoTf.text = ""
        isSearchActive = false
        searchResults.removeAll()
    }
    
    @objc func searchTextFieldDidChange(_ textField: UITextField) {
        searchDebounceTimer?.invalidate()
        videonoTf.text = ""
        
        let keyword = textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        if keyword.isEmpty {
            isSearchActive = false
            currentFeed = segmentController.selectedSegmentIndex == 0 ? diyFeed : storiesFeed
            tblVw.reloadData()
            return
        }
        
        guard keyword.count >= 1 else { return }
        
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            self?.searchByKeyword(keyword: keyword)
        }
    }
    
    @objc func videoNumberTextFieldDidChange(_ textField: UITextField) {
        searchTf.text = ""
        searchDebounceTimer?.invalidate()
    }
    
    func searchByKeyword(keyword: String) {
        showLoader()
        guard !keyword.isEmpty else { return }
        
        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? keyword
        let url = API.EDUTAIN_SEARCH + "?keyword=\(encodedKeyword)"
        
        NetworkManager.shared.request(urlString: url, method: .GET) { [weak self] (result: Result<APIResponse<[Feed]>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.hideLoader()
                let currentKeyword = self.searchTf.text?.trimmingCharacters(in: .whitespaces) ?? ""
                guard currentKeyword == keyword else { return }
                
                switch result {
                case .success(let info):
                    if info.success, let data = info.data {
                        let currentFCategory = self.getCurrentFCategory()
                        
                        self.searchResults = data.filter { feed in
                            return self.feedMatchesFCategory(feed, fCategory: currentFCategory)
                        }
                        
                        self.isSearchActive = true
                        self.currentFeed = self.searchResults
                        self.tblVw.reloadData()
                        
                        if self.searchResults.isEmpty {
                            self.showNoResultsMessage(for: keyword)
                        } else if !self.currentFeed.isEmpty {
                            self.tblVw.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                        }
                    } else {
                        self.showAlert(msg: info.description)
                    }
                case .failure(let error):
                    self.showAlert(msg: error.localizedDescription)
                }
            }
        }
    }
    
    func searchBySerialNumber(serialNumber: Int) {
        let sourceData = segmentController.selectedSegmentIndex == 0 ? diyFeed : storiesFeed
        
        if let foundFeed = sourceData.first(where: { $0.serial_number == serialNumber }) {
            isSearchActive = true
            searchResults = [foundFeed]
            currentFeed = searchResults
            tblVw.reloadData()
            
            if !currentFeed.isEmpty {
                tblVw.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        } else {
            searchSerialNumberFromAPI(serialNumber: serialNumber)
        }
    }
    
    func searchSerialNumberFromAPI(serialNumber: Int) {
        showLoader()
        let url = API.EDUTAIN_SEARCH + "?keyword=\(serialNumber)"
        
        NetworkManager.shared.request(urlString: url, method: .GET) { [weak self] (result: Result<APIResponse<[Feed]>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.hideLoader()

                switch result {
                case .success(let info):
                    if info.success, let data = info.data {
                        let currentFCategory = self.getCurrentFCategory()
                        
                        self.searchResults = data.filter { feed in
                            return self.feedMatchesFCategory(feed, fCategory: currentFCategory) && feed.serial_number == serialNumber
                        }
                        
                        self.isSearchActive = true
                        self.currentFeed = self.searchResults
                        self.tblVw.reloadData()
                        
                        if self.searchResults.isEmpty {
                            self.showNoResultsMessage(for: "Video #\(serialNumber)")
                        } else {
                            self.tblVw.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        }
                    } else {
                        self.showAlert(msg: info.description)
                    }
                case .failure(let error):
                    self.showAlert(msg: error.localizedDescription)
                }
            }
        }
    }
    
    func showNoResultsMessage(for searchTerm: String) {
        let category = segmentController.selectedSegmentIndex == 0 ? "DIY" : "Stories"
        showAlert(msg: "No results found for \(searchTerm) in \(category)")
    }
    
    func likeFeed(at index: Int) {
        guard index < currentFeed.count else { return }
        let feed = currentFeed[index]
        let feedId = feed.id
        let url = API.LIKE_FEED + feedId + "/like"
        
        NetworkManager.shared.request(urlString: url, method: .POST) { [weak self] (result: Result<APIResponse<LikeResponse>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let info):
                    if info.success, let data = info.data {
                        self.currentFeed[index].likesCount = data.likes_count
                        self.currentFeed[index].isLiked = data.is_liked
                        
                        if self.isSearchActive {
                            if let searchIndex = self.searchResults.firstIndex(where: { $0.id == feedId }) {
                                self.searchResults[searchIndex].likesCount = data.likes_count
                                self.searchResults[searchIndex].isLiked = data.is_liked
                            }
                        }
                        
                        if let allIndex = self.allFeed.firstIndex(where: { $0.id == feedId }) {
                            self.allFeed[allIndex].likesCount = data.likes_count
                            self.allFeed[allIndex].isLiked = data.is_liked
                        }
                        
                        if self.segmentController.selectedSegmentIndex == 0 {
                            if let diyIndex = self.diyFeed.firstIndex(where: { $0.id == feedId }) {
                                self.diyFeed[diyIndex].likesCount = data.likes_count
                                self.diyFeed[diyIndex].isLiked = data.is_liked
                            }
                        } else {
                            if let storiesIndex = self.storiesFeed.firstIndex(where: { $0.id == feedId }) {
                                self.storiesFeed[storiesIndex].likesCount = data.likes_count
                                self.storiesFeed[storiesIndex].isLiked = data.is_liked
                            }
                        }
                    } else {
                        self.showAlert(msg: info.description)
                    }
                    
                case .failure(let error):
                    self.showAlert(msg: error.localizedDescription)
                    let indexPath = IndexPath(row: index, section: 0)
                    self.tblVw.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
    }
    
    func postQuickComment(feedId: String, comment: String, at index: Int, completion: @escaping (Bool) -> Void) {
        let url = API.POST_COMMENT
        let parameters: [String: Any] = ["feed_id": feedId, "comment": comment]
        
        NetworkManager.shared.request(urlString: url, method: .POST, parameters: parameters) { [weak self] (result: Result<APIResponse<EmptyResponse>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let info):
                    if info.success {
                        self.currentFeed[index].commentsCount += 1
                        
                        if self.isSearchActive {
                            if let searchIndex = self.searchResults.firstIndex(where: { $0.id == feedId }) {
                                self.searchResults[searchIndex].commentsCount += 1
                            }
                        }
                        
                        if let allIndex = self.allFeed.firstIndex(where: { $0.id == feedId }) {
                            self.allFeed[allIndex].commentsCount += 1
                        }
                        
                        if self.segmentController.selectedSegmentIndex == 0 {
                            if let diyIndex = self.diyFeed.firstIndex(where: { $0.id == feedId }) {
                                self.diyFeed[diyIndex].commentsCount += 1
                            }
                        } else {
                            if let storiesIndex = self.storiesFeed.firstIndex(where: { $0.id == feedId }) {
                                self.storiesFeed[storiesIndex].commentsCount += 1
                            }
                        }
                        
                        completion(true)
                        self.showSuccessToast(message: "Comment posted!")
                    } else {
                        self.showAlert(msg: info.description)
                        completion(false)
                    }
                case .failure(let error):
                    self.showAlert(msg: error.localizedDescription)
                    completion(false)
                }
            }
        }
    }
    
    func showSuccessToast(message: String) {
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
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
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
    
    // MARK: - 📱 WhatsApp Share (Direct Open - Fixed)

    func handleWhatsAppShare(at index: Int, feed: Feed, updateCountClosure: @escaping () -> Void) {
        // Check if WhatsApp is installed
        guard let testURL = URL(string: "whatsapp://"),
              UIApplication.shared.canOpenURL(testURL) else {
            showWhatsAppNotInstalledAlert()
            return
        }
        
        // Update count locally
        self.currentFeed[index].whatsappShareCount += 1
        
        if self.isSearchActive {
            if let searchIndex = self.searchResults.firstIndex(where: { $0.id == feed.id }) {
                self.searchResults[searchIndex].whatsappShareCount += 1
            }
        }
        
        if let allIndex = self.allFeed.firstIndex(where: { $0.id == feed.id }) {
            self.allFeed[allIndex].whatsappShareCount += 1
        }
        
        if self.segmentController.selectedSegmentIndex == 0 {
            if let diyIndex = self.diyFeed.firstIndex(where: { $0.id == feed.id }) {
                self.diyFeed[diyIndex].whatsappShareCount += 1
            }
        } else {
            if let storiesIndex = self.storiesFeed.firstIndex(where: { $0.id == feed.id }) {
                self.storiesFeed[storiesIndex].whatsappShareCount += 1
            }
        }
        
        // Update UI
        updateCountClosure()
        
        // Open WhatsApp directly
        openWhatsAppDirect(with: feed)
    }

    func openWhatsAppDirect(with feed: Feed) {
        // Create simple share text (avoid special characters)
        let title = feed.heading
        let description = feed.description.stripHTML()
        let youtubeLink = feed.youtubeVideo ?? ""
        
        // Build text without emojis for URL (emojis can break URL encoding)
        var shareText = "\(title)\n\n"
        shareText += "\(description)\n\n"
        
        if !youtubeLink.isEmpty {
            shareText += "Link: \(youtubeLink)\n\n"
        }
        
        shareText += "Download SchoolFirst App for more!"
        
        // Proper URL encoding
        guard let encodedText = shareText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("❌ Failed to encode text")
            return
        }
        
        // Build WhatsApp URL
        let urlString = "whatsapp://send?text=\(encodedText)"
        
        guard let url = URL(string: urlString) else {
            print("❌ Failed to create URL")
            return
        }
        
        // Open WhatsApp
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func showWhatsAppNotInstalledAlert() {
        let alert = UIAlertController(
            title: "WhatsApp Not Installed",
            message: "WhatsApp is not installed on your device. Would you like to download it?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Download", style: .default) { _ in
            if let appStoreURL = URL(string: "https://apps.apple.com/app/whatsapp-messenger/id310633997") {
                UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    // MARK: - 📤 General Share (iOS Share Sheet)
    
    func shareContent(feed: Feed, sourceView: UIView, completion: @escaping (Bool) -> Void) {
        let shareText = """
        📚 \(feed.heading)
        
        \(feed.description.stripHTML())
        
        🔗 \(feed.youtubeVideo ?? "")
        
        📲 Download SchoolFirst App for more!
        """
        
        var itemsToShare: [Any] = [shareText]
        
        if let imageUrlString = feed.image, let imageUrl = URL(string: imageUrlString) {
            itemsToShare.append(imageUrl)
        }
        
        if let youtubeUrl = feed.youtubeVideo, let url = URL(string: youtubeUrl) {
            itemsToShare.append(url)
        }
        
        let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
        }
        
        activityVC.completionWithItemsHandler = { _, success, _, _ in
            completion(success)
        }
        
        present(activityVC, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension EdutainmentVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentFeed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feed = currentFeed[indexPath.row]
        
        if segmentController.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EdutainCell") as! EdutainCell
            cell.setup(feed: feed, index: indexPath.row)
            cell.btnLike.tag = indexPath.row
            cell.whatsappBtn.tag = indexPath.row
            cell.shareBtn.tag = indexPath.row
            cell.commentBtn.tag = indexPath.row
            
            cell.likeClicked = { [weak self] index in
                self?.likeFeed(at: index)
            }
            
            cell.whatsappClicked = { [weak self] index, feed in
                self?.handleWhatsAppShare(at: index, feed: feed) {
                    cell.updateWhatsappCount()
                }
            }
            
            cell.shareClicked = { [weak self] index, feed in
                self?.shareContent(feed: feed, sourceView: cell.shareBtn) { success in
                    if success {
                        cell.updateShareCount()
                    }
                }
            }
            
            cell.commentClicked = { [weak self] index, feed in
                self?.navigateToComments(feed: feed, cellType: .diy)
            }
            
            cell.tagClicked = { [weak self] index, feed, commentText in
                self?.postQuickComment(feedId: feed.id, comment: commentText, at: index) { success in
                    if success {
                        cell.incrementCommentCount()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            cell.resetTagSelection()
                        }
                    } else {
                        cell.resetTagSelection()
                    }
                }
            }
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StoriesCell") as! StoriesCell
            cell.setup(feed: feed, index: indexPath.row)
            cell.btnLike.tag = indexPath.row
            cell.whatsappBtn.tag = indexPath.row
            cell.shareBTn.tag = indexPath.row
            cell.commentBtn.tag = indexPath.row
            
            cell.likeClicked = { [weak self] index in
                self?.likeFeed(at: index)
            }
            
            cell.whatsappClicked = { [weak self] index, feed in
                self?.handleWhatsAppShare(at: index, feed: feed) {
                    cell.updateWhatsappCount()
                }
            }
            
            cell.shareClicked = { [weak self] index, feed in
                self?.shareContent(feed: feed, sourceView: cell.shareBTn) { success in
                    if success {
                        cell.updateShareCount()
                    }
                }
            }
            
            cell.commentClicked = { [weak self] index, feed in
                self?.stopAllVideos()
                self?.navigateToComments(feed: feed, cellType: .stories)
            }
            
            cell.tagClicked = { [weak self] index, feed, commentText in
                self?.postQuickComment(feedId: feed.id, comment: commentText, at: index) { success in
                    if success {
                        cell.incrementCommentCount()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            cell.resetTagSelection()
                        }
                    } else {
                        cell.resetTagSelection()
                    }
                }
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return segmentController.selectedSegmentIndex == 0 ? UITableView.automaticDimension : 420
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let storiesCell = cell as? StoriesCell {
            storiesCell.stopVideo()
        }
    }
}

// MARK: - UIScrollViewDelegate
extension EdutainmentVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        stopInvisibleVideos()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
}

// MARK: - UITextFieldDelegate
extension EdutainmentVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == searchTf {
            searchDebounceTimer?.invalidate()
            let keyword = searchTf.text?.trimmingCharacters(in: .whitespaces) ?? ""
            if !keyword.isEmpty {
                searchByKeyword(keyword: keyword)
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == searchTf {
            videonoTf.text = ""
        } else if textField == videonoTf {
            searchTf.text = ""
            searchDebounceTimer?.invalidate()
            if isSearchActive {
                isSearchActive = false
                currentFeed = segmentController.selectedSegmentIndex == 0 ? diyFeed : storiesFeed
                tblVw.reloadData()
            }
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == searchTf {
            searchDebounceTimer?.invalidate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self else { return }
                self.isSearchActive = false
                self.currentFeed = self.segmentController.selectedSegmentIndex == 0 ? self.diyFeed : self.storiesFeed
                self.tblVw.reloadData()
            }
        }
        return true
    }
}
