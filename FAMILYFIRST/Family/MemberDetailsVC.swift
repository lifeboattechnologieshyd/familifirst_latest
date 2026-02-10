//
//  MemberDetailsVC.swift
//  FamilyFirst
//
//  Created by Lifeboat on 10/01/26.
//

import UIKit

class MemberDetailsVC: UIViewController {
    
    @IBOutlet weak var tblVw: UITableView!
    
    var member: FamilyMember?
    var notesList: [String] = []
    var memberEvents: [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        setupData()
        setupTableView()
        
        if memberEvents.isEmpty {
            fetchMemberEvents()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupData() {
        if let hobbies = member?.notes?.hobbies {
            notesList = hobbies
        }
        tblVw.reloadData()
    }
    
    private func setupTableView() {
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.separatorStyle = .none
        
        tblVw.register(UINib(nibName: "DetailsCell", bundle: nil), forCellReuseIdentifier: "DetailsCell")
        tblVw.register(UINib(nibName: "NotesCell", bundle: nil), forCellReuseIdentifier: "NotesCell")
        tblVw.register(UINib(nibName: "AddAnotherNoteCell", bundle: nil), forCellReuseIdentifier: "AddAnotherNoteCell")
        tblVw.register(UINib(nibName: "EventsCell", bundle: nil), forCellReuseIdentifier: "EventsCell")
        tblVw.register(UINib(nibName: "CreateEventCell", bundle: nil), forCellReuseIdentifier: "CreateEventCell")
    }
    
    private func fetchMemberEvents() {
        guard let memberId = member?.effectiveId else { return }
        
        let urlString = "\(API.GET_EVENTS)?event_users=\(memberId)"
        
        NetworkManager.shared.request(
            urlString: urlString,
            method: .GET
        ) { [weak self] (result: Result<APIResponse<[Event]>, NetworkError>) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let events = response.data {
                        self?.memberEvents = events.sorted { ($0.eventDate ?? Date()) < ($1.eventDate ?? Date()) }
                        self?.tblVw.reloadData()
                    }
                case .failure(let error):
                    print("Error fetching events: \(error)")
                }
            }
        }
    }
    
    private func fetchMemberDetails() {
        guard let memberId = member?.effectiveId else { return }
        
        let urlString = "\(API.FAMILY_UPDATE_MEMBER)/\(memberId)"
        
        NetworkManager.shared.request(
            urlString: urlString,
            method: .GET
        ) { [weak self] (result: Result<APIResponse<FamilyMember>, NetworkError>) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let updatedMember = response.data {
                        self?.member = updatedMember
                        self?.setupData()
                    }
                case .failure(let error):
                    print("Error fetching member: \(error)")
                }
            }
        }
    }
    
    private func showToast(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            alert.dismiss(animated: true)
        }
    }
    
    private func showAddNoteAlert() {
        let alert = UIAlertController(title: "Add Note", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Enter note" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let note = alert.textFields?.first?.text, !note.isEmpty {
                self?.notesList.append(note)
                self?.tblVw.reloadData()
            }
        })
        present(alert, animated: true)
    }
    
    private func navigateToEditMemberVC() {
        print("Navigating to EditMemberVC")
        
        guard let member = member else {
            print("Member is nil")
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "EditMemberVC") as? EditMemberVC else {
            print("Failed to instantiate EditMemberVC")
            return
        }
        
        vc.member = member
        vc.onMemberUpdated = { [weak self] in
            self?.fetchMemberDetails()
        }
        vc.onMemberDeleted = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        vc.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MemberDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let notesCount = max(notesList.count, 1)
        let eventsCount = max(memberEvents.count, 1)
        return 1 + notesCount + 1 + eventsCount + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsCell", for: indexPath) as! DetailsCell
            
            if let member = member {
                cell.configure(with: member)
            }
            
            cell.onShowToast = { [weak self] msg in
                self?.showToast(message: msg)
            }
            
            cell.onBackTapped = { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            
            cell.onEditTapped = { [weak self] in
                print("onEditTapped closure called")
                self?.navigateToEditMemberVC()
            }
            
            return cell
        }
        
        let notesCount = max(notesList.count, 1)
        let notesEndIndex = notesCount
        
        if indexPath.row <= notesEndIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotesCell", for: indexPath) as! NotesCell
            if notesList.isEmpty {
                cell.notesLbl.text = "No notes added"
                cell.deleteBtn.isHidden = true
                cell.noteseditBtn.isHidden = true
            } else {
                cell.notesLbl.text = notesList[indexPath.row - 1]
                cell.deleteBtn.isHidden = false
                cell.noteseditBtn.isHidden = false
            }
            return cell
        }
        
        if indexPath.row == notesEndIndex + 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddAnotherNoteCell", for: indexPath) as! AddAnotherNoteCell
            return cell
        }
        
        let eventsCount = max(memberEvents.count, 1)
        let eventsStartIndex = notesEndIndex + 2
        let eventsEndIndex = eventsStartIndex + eventsCount - 1
        
        if indexPath.row >= eventsStartIndex && indexPath.row <= eventsEndIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventsCell", for: indexPath) as! EventsCell
            if memberEvents.isEmpty {
                cell.eventnameLbl.text = "No events"
                cell.dateLbl.text = ""
                cell.dayLbl.text = ""
                cell.img1.isHidden = true
                cell.img2.isHidden = true
                cell.img3.isHidden = true
                cell.moreBtn.isHidden = true
            } else {
                let eventIndex = indexPath.row - eventsStartIndex
                cell.configure(with: memberEvents[eventIndex])
            }
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateEventCell", for: indexPath) as! CreateEventCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 { return 418 }
        
        let notesCount = max(notesList.count, 1)
        let notesEndIndex = notesCount
        
        if indexPath.row <= notesEndIndex { return 80 }
        if indexPath.row == notesEndIndex + 1 { return 88 }
        
        let eventsCount = max(memberEvents.count, 1)
        let eventsStartIndex = notesEndIndex + 2
        let eventsEndIndex = eventsStartIndex + eventsCount - 1
        
        if indexPath.row >= eventsStartIndex && indexPath.row <= eventsEndIndex {
            return 90 
        }
        
        return 40
    }
}
