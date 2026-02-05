//
//  CreateEventVC.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 17/01/26.
//

import UIKit

class CreateEventVC: UIViewController {

    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var createeventBtn: UIButton!
    
    var familyMembers: [FamilyMember] = []
    var onEventCreated: (() -> Void)?
    var selectedUserIds: Set<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupTableView()
        topVw.addBottomShadow()
        createeventBtn.addTarget(self, action: #selector(createEventTapped), for: .touchUpInside)
        tblVw.reloadData()
    }
    
    func setupTableView() {
        tblVw.register(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "EventCell")
        tblVw.register(UINib(nibName: "MemberCell", bundle: nil), forCellReuseIdentifier: "MemberCell")
        
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.separatorStyle = .none
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func createEventTapped() {
        
        guard let eventCell = tblVw.cellForRow(at: IndexPath(row: 0, section: 0)) as? EventCell else {
            print("Error: Could not find EventCell")
            return
        }
        
        guard let name = eventCell.eventTf.text, !name.isEmpty,
              let date = eventCell.dateTf.text, !date.isEmpty,
              let time = eventCell.timeTf.text, !time.isEmpty,
              let desc = eventCell.descriptionTv.text else {
            showAlert(message: "Please fill all fields")
            return
        }
        let parameters: [String: Any] = [
            "event_type": "family gather",
            "event_name": name,
            "date": date,
            "time": time,
            "description": desc,
            "event_users": Array(selectedUserIds).filter { !$0.isEmpty },
            "colour_code": eventCell.selectedColorHex
        ]
        
        print("Macha Sending Params: \(parameters)")
        
        self.createeventBtn.isEnabled = false
        
        NetworkManager.shared.request(urlString: API.CREATE_EVENT, method: .POST, parameters: parameters) { [weak self] (result: Result<APIResponse<EventResponseData>, NetworkError>) in
            
            DispatchQueue.main.async {
                self?.createeventBtn.isEnabled = true
                
                switch result {
                case .success(let response):
                    if response.success {
                        print("✅ Success: \(response.data?.event_name ?? "Event")")
                        self?.showAlert(message: "Event Created Successfully!") {
                            self?.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        self?.showAlert(message: response.description)
                    }
                    
                case .failure(let error):
                    print("❌ Error: \(error)")
                    self?.showAlert(message: "Something went wrong")
                }
            }
        }
    }
    
    func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?() }))
        self.present(alert, animated: true)
    }
}

extension CreateEventVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return familyMembers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as! MemberCell
            
            let member = familyMembers[indexPath.row]
            let memberId = member.memberId ?? ""
            
            let isSelected = selectedUserIds.contains(memberId)
            
            cell.configure(with: member, isSelected: isSelected)
            
            cell.onCheckTapped = { [weak self] in
                guard let self = self else { return }
                
                print("Macha, button tapped for: \(member.fullName ?? "")")
                
                if self.selectedUserIds.contains(memberId) {
                    self.selectedUserIds.remove(memberId)
                } else {
                    self.selectedUserIds.insert(memberId)
                }
                
                tableView.reloadRows(at: [indexPath], with: .none)
            }
            
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            guard let memberID = familyMembers[indexPath.row].memberId else { return }
            
            if selectedUserIds.contains(memberID) {
                selectedUserIds.remove(memberID)
            } else {
                selectedUserIds.insert(memberID)
            }
            
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 610
        } else {
            return 80
        }
    }
}
