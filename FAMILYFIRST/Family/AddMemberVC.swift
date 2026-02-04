//
//  AddMemberVC.swift
//  FamilyFirst
//
//  Created by Lifeboat on 09/01/26.
//

import UIKit

class AddMemberVC: UIViewController {

    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var addBtn: UIButton! 
    
    var onMemberAdded: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        topVw.addBottomShadow()
        self.navigationItem.hidesBackButton = true
    }

    private func setupTableView() {
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.register(UINib(nibName: "AddFamilyMemberCell", bundle: nil), forCellReuseIdentifier: "AddFamilyMemberCell")
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addBtnTapped(_ sender: UIButton) {
        guard let cell = tblVw.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddFamilyMemberCell else { return }
        
        guard let params = cell.getFormData() else {
            showAlert("Please enter valid Name, Mobile (10 digits) and Relation.")
            return
        }
        
        // 3. Call API
        addFamilyMember(params: params)
    }
    
    private func addFamilyMember(params: [String: Any]) {
        addBtn.isEnabled = false
        addBtn.setTitle("Adding...", for: .normal)
        
        NetworkManager.shared.request(
            urlString: API.FAMILY_MASTER,
            method: .POST,
            parameters: params
        ) { [weak self] (result: Result<APIResponse<AddFamilyMemberResponse>, NetworkError>) in
            
            DispatchQueue.main.async {
                self?.addBtn.isEnabled = true
                self?.addBtn.setTitle("Add Member", for: .normal)
                
                switch result {
                case .success(let response):
                    if response.success {
                        self?.showSuccessAndPop()
                    } else {
                        self?.showAlert(response.description)
                    }
                case .failure(let error):
                    self?.showAlert(error.localizedDescription)
                }
            }
        }
    }
    
    private func showSuccessAndPop() {
        let alert = UIAlertController(title: "Success", message: "Family member added successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.onMemberAdded?()
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension AddMemberVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddFamilyMemberCell", for: indexPath) as! AddFamilyMemberCell
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 670
    }
}
