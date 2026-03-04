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
        let url = API.EDUTAIN_FEED
        
        NetworkManager.shared.request(urlString: url, method: .GET) { [weak self] (result: Result<APIResponse<[Feed]>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.hideLoader()
                
                switch result {
                case .success(let info):
                    if let data = info.data {
                        // 👈 Filter by categories array containing "Prosperity Tips"
                        self.feed = data.filter { feed in
                            guard let categories = feed.categories else { return false }
                            return categories.contains("Prosperity Tips")
                        }
                        
                        print("✅ Prosperity Tips count: \(self.feed.count)")
                        self.tblView.reloadData()
                        
                        if self.feed.isEmpty {
                            self.showAlert(msg: "No Prosperity Tips found")
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
    
    func navigateToComments(feed: Feed) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "CommentsVC") as? CommentsVC else { return }
        vc.feed = feed
        vc.cellType = .diy
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func likeFeed(at index: Int) {
        guard index < feed.count else { return }
        let feedId = feed[index].id
        let url = API.LIKE_FEED + feedId + "/like"
        
        NetworkManager.shared.request(urlString: url, method: .POST) { [weak self] (result: Result<APIResponse<LikeResponse>, NetworkError>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let info):
                    if info.success, let data = info.data {
                        self.feed[index].likesCount = data.likes_count
                        self.feed[index].isLiked = data.is_liked
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
        let parameters: [String: Any] = ["feed_id": feedId, "comment": comment]
        
        NetworkManager.shared.request(urlString: url, method: .POST, parameters: parameters) { [weak self] (result: Result<APIResponse<EmptyResponse>, NetworkError>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let info):
                    if info.success {
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
        guard let testURL = URL(string: "whatsapp://send?text=test"), UIApplication.shared.canOpenURL(testURL) else {
            showWhatsAppNotInstalledAlert()
            return
        }
        callWhatsAppShareAPI(feedId: feed.id) { [weak self] success in
            guard let self = self, success else { return }
            self.feed[index].whatsappShareCount += 1
            updateCountClosure()
            _ = self.openWhatsApp(with: feed)
        }
    }
    
    func callWhatsAppShareAPI(feedId: String, completion: @escaping (Bool) -> Void) {
        let url = API.WHATSAPP_SHARE
        let parameters: [String: Any] = ["feed_id": feedId]
        NetworkManager.shared.request(urlString: url, method: .POST, parameters: parameters) { (result: Result<APIResponse<EmptyResponse>, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let info): completion(info.success)
                case .failure(_): completion(false)
                }
            }
        }
    }
    
    func openWhatsApp(with feed: Feed) -> Bool {
        let shareText = "📚 *\(feed.heading)*\n\n\(feed.description.stripHTML())\n\n🔗 \(feed.youtubeVideo ?? "")\n\n📲 Download FamilyFirst App for more!"
        guard let encodedText = shareText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "whatsapp://send?text=\(encodedText)"),
              UIApplication.shared.canOpenURL(url) else { return false }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        return true
    }
    
    func showWhatsAppNotInstalledAlert() {
        let alert = UIAlertController(title: "WhatsApp Not Installed", message: "WhatsApp is not installed. Would you like to download it?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Download", style: .default) { _ in
            if let url = URL(string: "https://apps.apple.com/app/whatsapp-messenger/id310633997") {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func shareContent(feed: Feed, sourceView: UIView, completion: @escaping (Bool) -> Void) {
        let shareText = "📚 \(feed.heading)\n\n\(feed.description.stripHTML())\n\n🔗 \(feed.youtubeVideo ?? "")\n\n📲 Download FamilyFirst App for more!"
        var items: [Any] = [shareText]
        if let imgUrl = feed.image, let url = URL(string: imgUrl) { items.append(url) }
        if let ytUrl = feed.youtubeVideo, let url = URL(string: ytUrl) { items.append(url) }
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
        }
        activityVC.completionWithItemsHandler = { _, success, _, _ in completion(success) }
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
        UIView.animate(withDuration: 0.3, animations: { toastLabel.alpha = 1 }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, animations: { toastLabel.alpha = 0 }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}

extension ProsperityTipsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return feed.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EdutainCell") as! EdutainCell
        let feedItem = feed[indexPath.row]
        cell.setup(feed: feedItem, index: indexPath.row)
        cell.btnLike.tag = indexPath.row
        cell.whatsappBtn.tag = indexPath.row
        cell.shareBtn.tag = indexPath.row
        cell.commentBtn.tag = indexPath.row
        cell.likeClicked = { [weak self] index in self?.likeFeed(at: index) }
        cell.whatsappClicked = { [weak self] index, feed in
            self?.handleWhatsAppShare(at: index, feed: feed) { cell.updateWhatsappCount() }
        }
        cell.shareClicked = { [weak self] index, feed in
            self?.shareContent(feed: feed, sourceView: cell.shareBtn) { success in
                if success {
                    self?.feed[index].shareCount = (self?.feed[index].shareCount ?? 0) + 1
                    cell.updateShareCount()
                }
            }
        }
        cell.commentClicked = { [weak self] _, feed in self?.navigateToComments(feed: feed) }
        cell.tagClicked = { [weak self] index, feed, commentText in
            self?.postQuickComment(feedId: feed.id, comment: commentText, at: index) { success in
                success ? cell.incrementCommentCount() : cell.resetTagSelection()
                if success { DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { cell.resetTagSelection() } }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
