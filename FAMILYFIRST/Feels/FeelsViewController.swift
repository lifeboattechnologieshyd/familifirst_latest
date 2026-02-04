//
//  Untitled.swift
//  FamilyFirst
//
//  Created by Lifeboat on 14/01/26.
//

import UIKit

class FeelsViewController: UIViewController {
    
    @IBOutlet weak var goBtn: UIButton!
    @IBOutlet weak var searchTf: UITextField!
    @IBOutlet weak var fflogoImgVw: UIImageView!
    @IBOutlet weak var colVw: UICollectionView!
    @IBOutlet weak var videonoTf: UITextField!
    
    var items = [FeelItem]()
    var page = 1
    var pageSize = 20
    var isLoading = false
    var canLoadMore = true
    var searchText = ""
    var serialNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupTextFields()
        
        getFeels()
    }
    
    private func setupUI() {
        fflogoImgVw.addCardShadow()
    }
    
    private func setupCollectionView() {
        colVw.delegate = self
        colVw.dataSource = self
        colVw.register(UINib(nibName: "FeelsCollectionViewCell", bundle: nil),
                       forCellWithReuseIdentifier: "FeelsCollectionViewCell")
    }
    
    private func setupTextFields() {
        searchTf.delegate = self
        videonoTf.delegate = self
        
        searchTf.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        videonoTf.addTarget(self, action: #selector(videoNoTextChanged), for: .editingChanged)
    }
    
    
    @IBAction func onClickBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickGo(_ sender: UIButton) {
        let serial = videonoTf.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if serial.isEmpty {
            showAlert(msg: "Please enter a video number")
            return
        }
        
        view.endEditing(true)
        
        searchTf.text = ""
        searchText = ""
        
        serialNumber = serial
        page = 1
        canLoadMore = false
        
        getFeels()
    }
    
    
    @objc func searchTextChanged() {
        let query = searchTf.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        searchText = query
        serialNumber = ""
        videonoTf.text = ""
        
        page = 1
        canLoadMore = true
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: nil)
        perform(#selector(performSearch), with: nil, afterDelay: 0.5)
    }
    
    @objc func performSearch() {
        getFeels()
    }
    
    @objc func videoNoTextChanged() {
        let text = videonoTf.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if text.isEmpty {
            serialNumber = ""
            searchText = ""
            page = 1
            canLoadMore = true
            getFeels()
        }
    }
    
    
    func getFeels() {
        guard !isLoading else { return }
        
        isLoading = true
        showLoader()
        
        var url = API.GET_FEELS
        var params: [String] = []
        
        if !serialNumber.isEmpty {
            params.append("serial_number=\(serialNumber)")
        }
        else if !searchText.isEmpty {
            params.append("page_size=\(pageSize)")
            params.append("page=\(page)")
            if let encoded = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                params.append("title=\(encoded)")
            }
        }
        else {
            params.append("page_size=\(pageSize)")
            params.append("page=\(page)")
        }
        
        if !params.isEmpty {
            url += "?" + params.joined(separator: "&")
        }
        
        print("📡 Fetching Feels: \(url)")
        
        NetworkManager.shared.request(
            urlString: url,
            method: .GET,
            parameters: nil
        ) { [weak self] (result: Result<APIResponse<[FeelItem]>, NetworkError>) in
            
            guard let self = self else { return }
            
            self.isLoading = false
            
            DispatchQueue.main.async {
                self.hideLoader()
                
                switch result {
                case .success(let response):
                    if response.success {
                        self.handleSuccess(data: response.data ?? [])
                    } else {
                        self.showAlert(msg: response.description)
                    }
                    
                case .failure(let error):
                    self.handleError(error)
                }
            }
        }
    }
    
    private func handleSuccess(data: [FeelItem]) {
        print("✅ Received \(data.count) feels")
        
        // Check if can load more
        if data.count < pageSize {
            canLoadMore = false
        }
        
        // Update items
        if page == 1 {
            items = data
        } else {
            items.append(contentsOf: data)
        }
        
        colVw.reloadData()
        
        // Show message if no results
        if items.isEmpty {
            showAlert(msg: "No feels found")
        }
    }
    
    private func handleError(_ error: NetworkError) {
        var message = "Something went wrong"
        
        switch error {
        case .serverError(let msg):
            message = msg
        case .decodingError(let msg):
            message = msg
        case .invalidURL:
            message = "Invalid URL"
        case .noData:
            message = "No data received"
        case .noaccess:
            message = "Unauthorized access"
        }
        
        showAlert(msg: message)
    }
    
    
    func navigateToPlayer(index: Int) {
        let stbd = UIStoryboard(name: "Main", bundle: nil)
        let vc = stbd.instantiateViewController(identifier: "FeelPlayerController") as! FeelPlayerController
        vc.selected_feel_item = items[index]
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension FeelsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = colVw.dequeueReusableCell(withReuseIdentifier: "FeelsCollectionViewCell", for: indexPath) as! FeelsCollectionViewCell
        
        let item = items[indexPath.row]
        
        cell.imgVw.layer.cornerRadius = 8
        cell.btnPlay.tag = indexPath.row
        
        // Load thumbnail
        if let thumbnailURL = item.thumbnailImage, !thumbnailURL.isEmpty {
            cell.imgVw.loadImage(url: thumbnailURL)
        } else if let youtubeURL = item.youtubeVideo, let videoID = youtubeURL.extractYoutubeId() {
            cell.imgVw.loadImage(url: videoID.youtubeThumbnailURL())
        } else {
            cell.imgVw.image = UIImage(systemName: "photo")
        }
        
        // Set title
        cell.lblName.text = item.title ?? "No Title"
        
        // Play button callback
        cell.playClicked = { [weak self] index in
            self?.navigateToPlayer(index: index)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width - 8) / 2
        return CGSize(width: width, height: 284)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigateToPlayer(index: indexPath.row)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height
        
        // Load more when near bottom
        if offsetY > contentHeight - frameHeight - 200 {
            if !isLoading && canLoadMore && serialNumber.isEmpty {
                page += 1
                getFeels()
            }
        }
    }
}


extension FeelsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
