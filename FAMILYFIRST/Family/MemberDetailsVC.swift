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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        setupData()
        setupTableView()
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
}

extension MemberDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + max(notesList.count, 1) + 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsCell", for: indexPath) as! DetailsCell
            if let member = member { cell.configure(with: member) }
            
            cell.onShowToast = { [weak self] msg in self?.showToast(message: msg) }
            
            cell.onBackTapped = { [weak self] in
                self?.navigationController?.popViewController(animated: true)
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
        
        if indexPath.row == notesEndIndex + 2 {
            return tableView.dequeueReusableCell(withIdentifier: "EventsCell", for: indexPath) as! EventsCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateEventCell", for: indexPath) as! CreateEventCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 { return 418 }
        let notesEndIndex = max(notesList.count, 1)
        if indexPath.row <= notesEndIndex { return 80 }
        if indexPath.row == notesEndIndex + 1 { return 88 }
        if indexPath.row == notesEndIndex + 2 { return 90 }
        return 40
    }
}
