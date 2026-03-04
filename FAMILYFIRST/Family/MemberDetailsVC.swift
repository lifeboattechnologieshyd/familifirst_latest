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
        // 👈 Only add notes if they exist and are not empty
        notesList = []
        if let hobbies = member?.notes?.hobbies {
            // Filter out empty strings
            notesList = hobbies.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
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
    
    private func navigateToCreateEventVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "CreateEventVC") as? CreateEventVC else {
            print("Failed to instantiate CreateEventVC")
            return
        }
        
        if let member = member {
            vc.preSelectedMember = member
        }
        
        vc.onEventCreated = { [weak self] in
            self?.fetchMemberEvents()
        }
        
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MemberDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let notesCount = notesList.count
        let eventsCount = max(memberEvents.count, 1)
        
        // 👈 If no notes, don't show NotesCell and AddAnotherNoteCell
        if notesCount == 0 {
            // DetailsCell + EventsCells + CreateEventCell
            return 1 + eventsCount + 1
        } else {
            // DetailsCell + NotesCell + AddAnotherNoteCell + EventsCells + CreateEventCell
            return 1 + notesCount + 1 + eventsCount + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let hasNotes = !notesList.isEmpty  // 👈 Check if notes exist
        
        // Row 0: DetailsCell
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsCell", for: indexPath) as! DetailsCell
            
            if let member = member {
                // 👈 Pass hasNotes to configure
                cell.configure(with: member, hasNotes: hasNotes)
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
        
        // 👈 If no notes, skip directly to events
        if !hasNotes {
            // Events section starts at row 1
            let eventsCount = max(memberEvents.count, 1)
            let eventsStartIndex = 1
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
            
            // CreateEventCell (last cell)
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreateEventCell", for: indexPath) as! CreateEventCell
            cell.onCreateEventTapped = { [weak self] in
                self?.navigateToCreateEventVC()
            }
            return cell
        }
        
        // 👈 Notes exist - show notes section
        let notesCount = notesList.count
        let notesEndIndex = notesCount
        
        // Notes cells (row 1 to notesCount)
        if indexPath.row <= notesEndIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotesCell", for: indexPath) as! NotesCell
            cell.notesLbl.text = notesList[indexPath.row - 1]
            cell.deleteBtn.isHidden = false
            cell.noteseditBtn.isHidden = false
            return cell
        }
        
        // AddAnotherNoteCell
        let addNoteIndex = notesCount + 1
        if indexPath.row == addNoteIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddAnotherNoteCell", for: indexPath) as! AddAnotherNoteCell
            return cell
        }
        
        // Events section
        let eventsCount = max(memberEvents.count, 1)
        let eventsStartIndex = addNoteIndex + 1
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
        
        // CreateEventCell (last cell)
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateEventCell", for: indexPath) as! CreateEventCell
        cell.onCreateEventTapped = { [weak self] in
            self?.navigateToCreateEventVC()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let hasNotes = !notesList.isEmpty
        
        // DetailsCell - 👈 Reduced height when no notes
        if indexPath.row == 0 {
            return hasNotes ? 418 : 380  // 👈 Smaller height when no notes
        }
        
        // 👈 If no notes, skip to events
        if !hasNotes {
            let eventsCount = max(memberEvents.count, 1)
            let eventsStartIndex = 1
            let eventsEndIndex = eventsStartIndex + eventsCount - 1
            
            if indexPath.row >= eventsStartIndex && indexPath.row <= eventsEndIndex {
                return 90
            }
            
            // CreateEventCell
            return 40
        }
        
        // Notes exist
        let notesCount = notesList.count
        let notesEndIndex = notesCount
        
        // NotesCell
        if indexPath.row <= notesEndIndex { return 80 }
        
        // AddAnotherNoteCell
        let addNoteIndex = notesCount + 1
        if indexPath.row == addNoteIndex { return 50 }
        
        // EventsCell
        let eventsCount = max(memberEvents.count, 1)
        let eventsStartIndex = addNoteIndex + 1
        let eventsEndIndex = eventsStartIndex + eventsCount - 1
        
        if indexPath.row >= eventsStartIndex && indexPath.row <= eventsEndIndex {
            return 90
        }
        
        // CreateEventCell
        return 40
    }
}
