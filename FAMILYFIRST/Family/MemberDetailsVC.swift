//
//  MemberDetailsVC.swift
//  FamilyFirst
//
//  Created by Lifeboat on 10/01/26.
//

import UIKit

class MemberDetailsVC: UIViewController {
    
    @IBOutlet weak var tblVw: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        setupTableView()
    }
    
    private func setupTableView() {
        tblVw.delegate = self
        tblVw.dataSource = self
        
        tblVw.register(UINib(nibName: "DetailsCell", bundle: nil),forCellReuseIdentifier: "DetailsCell")
        tblVw.register(UINib(nibName: "NotesCell", bundle: nil),forCellReuseIdentifier: "NotesCell")
        tblVw.register(UINib(nibName: "AddAnotherNoteCell", bundle: nil),forCellReuseIdentifier: "AddAnotherNoteCell")
        tblVw.register(UINib(nibName: "EventsCell", bundle: nil),forCellReuseIdentifier: "EventsCell")
        tblVw.register(UINib(nibName: "CreateEventCell", bundle: nil),forCellReuseIdentifier: "CreateEventCell")
    }
}
extension MemberDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: "DetailsCell",for: indexPath) as! DetailsCell
        case 1:
            return tableView.dequeueReusableCell(withIdentifier: "NotesCell",for: indexPath) as! NotesCell
        case 2:
            return tableView.dequeueReusableCell(withIdentifier: "AddAnotherNoteCell",for: indexPath) as! AddAnotherNoteCell
        case 3:
            return tableView.dequeueReusableCell(withIdentifier: "EventsCell",for: indexPath) as! EventsCell
        case 4:
            return tableView.dequeueReusableCell(withIdentifier: "CreateEventCell",for: indexPath) as! CreateEventCell
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0: return 418
        case 1: return 80
        case 2: return 88
        case 3: return 90
        case 4: return 40
        default: return UITableView.automaticDimension
        }
    }
    
}
