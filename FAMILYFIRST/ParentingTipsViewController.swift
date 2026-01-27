//
//  ParentingTipsViewController.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 16/01/26.
//

import UIKit

class ParentingTipsViewController: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    
    var feed = [Feed]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchParentingTips()
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
    
    func fetchParentingTips() {
        let url = API.EDUTAIN_FEED + "?f_category=Ptips"
        NetworkManager.shared.request(urlString: url, method: .GET) { (result: Result<APIResponse<[Feed]>, NetworkError>) in
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
}

extension ParentingTipsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EdutainCell") as! EdutainCell
        cell.setup(feed: feed[indexPath.row])
        cell.likeClicked = { tag in
            if self.feed[indexPath.row].isLiked {
                
            } else {
                
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
