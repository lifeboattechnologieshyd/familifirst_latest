//
//  EditMemberVC.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 10/02/26.
//

import UIKit

class EditMemberVC: UIViewController {
    
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var deleteUser: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    var member: FamilyMember?
    var onMemberUpdated: (() -> Void)?
    var onMemberDeleted: (() -> Void)?
    
    private var editCell: EditCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        deleteUser.addCardShadow()
        topVw.addBottomShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupTableView() {
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.register(UINib(nibName: "EditCell", bundle: nil), forCellReuseIdentifier: "EditCell")
        
        tblVw.rowHeight = UITableView.automaticDimension
        tblVw.estimatedRowHeight = 600
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        print("Back button tapped")
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveBtnTapped(_ sender: UIButton) {
        guard let cell = editCell else {
            return
        }
        guard let params = cell.getFormData() else {
            showAlert("Please fill all required fields")
            return
        }
        updateMember(params: params)
    }
    
    @IBAction func deleteBtnTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Delete Member",
            message: "Are you sure you want to delete this family member?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteMember()
        })
        present(alert, animated: true)
    }
    
    private func updateMember(params: [String: Any]) {
        guard let memberId = member?.effectiveId else {
            showAlert("Member ID not found")
            return
        }
        
        
        let urlString = "\(API.FAMILY_UPDATE_MEMBER)/\(memberId)"
        showLoader()
        
        NetworkManager.shared.request(
            urlString: urlString,
            method: .PUT,
            parameters: params
        ) { [weak self] (result: Result<APIResponse<FamilyMemberResponse>, NetworkError>) in
            DispatchQueue.main.async {
                self?.hideLoader()
                switch result {
                case .success(let response):
                    if response.success {
                        self?.showAlertWithCompletion("Member updated successfully") {
                            self?.onMemberUpdated?()
                            self?.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        self?.showAlert(response.description ?? "Update failed")
                    }
                case .failure(let error):
                    self?.showAlert("Error: \(error.localizedDescription)")
                }
            }
        }
    }

    private func deleteMember() {
            
        guard let memberId = member?.effectiveId else {
            showAlert("Member ID not found")
            return
        }
        
        
        let urlString = "\(API.FAMILY_DELETE_MEMBER)/\(memberId)"
        
        showLoader()
        
        NetworkManager.shared.request(
            urlString: urlString,
            method: .DELETE
        ) { [weak self] (result: Result<APIResponse<DeleteResponse>, NetworkError>) in
            DispatchQueue.main.async {
                self?.hideLoader()
                switch result {
                case .success(let response):
                    if response.success {
                        self?.showAlertWithCompletion("Member deleted successfully") {
                            self?.onMemberDeleted?()
                            self?.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        self?.showAlert(response.data?.error ?? response.description ?? "Delete failed")
                    }
                case .failure(let error):
                    self?.showAlert("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAlertWithCompletion(_ message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion()
        })
        present(alert, animated: true)
    }
}

extension EditMemberVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditCell", for: indexPath) as! EditCell
        cell.selectionStyle = .none
        cell.backgroundColor = .white
        cell.contentView.backgroundColor = .white
        
        if let member = member {
            cell.configure(with: member)
        }
        
        editCell = cell
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 800
    }
}
