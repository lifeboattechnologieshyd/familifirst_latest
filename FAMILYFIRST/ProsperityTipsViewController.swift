//
//  ProsperityTipsViewController.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 16/01/26.
//

import UIKit

class ProsperityTipsViewController: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    
    var feed = [Feed]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchProsperityTips()
    }
    
    private func setupUI() {
        topView.addBottomShadow()
        tblView.register(UINib(nibName: "EdutainCell", bundle: nil), forCellReuseIdentifier: "EdutainCell")
        tblView.dataSource = self
        tblView.delegate = self
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func fetchProsperityTips() {
        showLoader()
        let url = API.EDUTAIN_FEED + "?f_category=Ftips"
        NetworkManager.shared.request(urlString: url, method: .GET) { (result: Result<APIResponse<[Feed]>, NetworkError>) in
            DispatchQueue.main.async {
                self.hideLoader()
            }
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.feed = data
                    }
                    DispatchQueue.main.async {
                        self.tblView.reloadData()
                    }
                } else {
                    self.showAlert(msg: info.description)
                }
            case .failure(let error):
                self.showAlert(msg: error.localizedDescription)
            }
        }
    }
    
    func navigateToComments(feed: Feed) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "CommentsVC") as? CommentsVC else { return }
        vc.feed = feed
        vc.cellType = .diy
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func likeFeed(at index: Int) {
        guard index < feed.count else { return }
        let feedItem = feed[index]
        let feedId = feedItem.id
        let url = API.LIKE_FEED + feedId + "/like"
        
        NetworkManager.shared.request(urlString: url, method: .POST) { [weak self] (result: Result<APIResponse<LikeResponse>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let info):
                    if info.success, let data = info.data {
                        self.feed[index].likesCount = data.likes_count
                        self.feed[index].isLiked = data.is_liked
                        
                        let indexPath = IndexPath(row: index, section: 0)
                        if let cell = self.tblView.cellForRow(at: indexPath) as? EdutainCell {
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
    
    func postQuickComment(feedId: String, comment: String, at index: Int, completion: @escaping (Bool) -> Void) {
        let url = API.POST_COMMENT
        
        let parameters: [String: Any] = [
            "feed_id": feedId,
            "comment": comment
        ]
        
        NetworkManager.shared.request(urlString: url, method: .POST, parameters: parameters) { [weak self] (result: Result<APIResponse<EmptyResponse>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let info):
                    if info.success {
                        print("✅ Quick comment posted successfully: \(comment)")
                        self.feed[index].commentsCount += 1
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
    
    func handleWhatsAppShare(at index: Int, feed: Feed, updateCountClosure: @escaping () -> Void) {
        let shareText = "test"
        guard let encodedText = shareText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let testURL = URL(string: "whatsapp://send?text=\(encodedText)"),
              UIApplication.shared.canOpenURL(testURL) else {
            showWhatsAppNotInstalledAlert()
            return
        }
        
        callWhatsAppShareAPI(feedId: feed.id) { [weak self] success in
            guard let self = self else { return }
            
            if success {
                self.feed[index].whatsappShareCount += 1
                updateCountClosure()
                _ = self.openWhatsApp(with: feed)
            }
        }
    }
    
    func callWhatsAppShareAPI(feedId: String, completion: @escaping (Bool) -> Void) {
        let url = API.WHATSAPP_SHARE
        let parameters: [String: Any] = ["feed_id": feedId]
        
        NetworkManager.shared.request(urlString: url, method: .POST, parameters: parameters) { (result: Result<APIResponse<EmptyResponse>, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let info):
                    completion(info.success)
                case .failure(_):
                    completion(false)
                }
            }
        }
    }
    
    func openWhatsApp(with feed: Feed) -> Bool {
        let shareText = """
        📚 *\(feed.heading)*
        
        \(feed.description.stripHTML())
        
        🔗 \(feed.youtubeVideo ?? "")
        
        📲 Download FamilyFirst App for more!
        """
        
        guard let encodedText = shareText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "whatsapp://send?text=\(encodedText)") else {
            return false
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return true
        } else {
            showWhatsAppNotInstalledAlert()
            return false
        }
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
    
    func shareContent(feed: Feed, sourceView: UIView, completion: @escaping (Bool) -> Void) {
        let shareText = """
        📚 \(feed.heading)
        
        \(feed.description.stripHTML())
        
        🔗 \(feed.youtubeVideo ?? "")
        
        📲 Download FamilyFirst App for more!
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
        
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            completion(success)
        }
        
        present(activityVC, animated: true)
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
}

extension ProsperityTipsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EdutainCell") as! EdutainCell
        let feedItem = feed[indexPath.row]
        
        cell.setup(feed: feedItem, index: indexPath.row)
        cell.btnLike.tag = indexPath.row
        cell.whatsappBtn.tag = indexPath.row
        cell.shareBtn.tag = indexPath.row
        cell.commentBtn.tag = indexPath.row
        
        cell.likeClicked = { [weak self] index in
            self?.likeFeed(at: index)
        }
        
        cell.whatsappClicked = { [weak self] index, feed in
            guard let self = self else { return }
            self.handleWhatsAppShare(at: index, feed: feed) {
                cell.updateWhatsappCount()
            }
        }
        
        cell.shareClicked = { [weak self] index, feed in
            guard let self = self else { return }
            self.shareContent(feed: feed, sourceView: cell.shareBtn) { success in
                if success {
                    self.feed[index].shareCount = (self.feed[index].shareCount ?? 0) + 1
                    cell.updateShareCount()
                }
            }
        }
        
        cell.commentClicked = { [weak self] index, feed in
            guard let self = self else { return }
            self.navigateToComments(feed: feed)
        }
        
        cell.tagClicked = { [weak self] index, feed, commentText in
            guard let self = self else { return }
            
            self.postQuickComment(feedId: feed.id, comment: commentText, at: index) { success in
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
