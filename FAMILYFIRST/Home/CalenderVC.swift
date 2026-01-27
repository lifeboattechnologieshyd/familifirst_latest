//
//  CalenderVC.swift
//  FamilyFirst
//
//  Created by Lifeboat on 13/01/26.
//
import UIKit

class CalenderVC: UIViewController {
    
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var upcomingBtn: UIButton!
    @IBOutlet weak var completedBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        topVw.addBottomShadow()
        
        
        tblVw.delegate = self
        tblVw.dataSource = self
        
        tblVw.register(UINib(nibName: "CalenderVCcell", bundle: nil),forCellReuseIdentifier: "CalenderVCcell")
        tblVw.register(UINib(nibName: "AddEventCell", bundle: nil),forCellReuseIdentifier: "AddEventCell")
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CalenderVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalenderVCcell",
                                                     for: indexPath) as! CalenderVCcell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddEventCell",
                                                     for: indexPath) as! AddEventCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row < 3 {
            return 130
        } else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < 3 {
            //            // Navigate from calendar cells
            //            let vc = UIStoryboard(name: "Main", bundle: nil)
            //                .instantiateViewController(withIdentifier: "DetailsVC") as! DetailsVC
            //            self.navigationController?.pushViewController(vc, animated: true)
            //        } else {
            //            // Navigate from event cell
            //            let vc = UIStoryboard(name: "Main", bundle: nil)
            //                .instantiateViewController(withIdentifier: "AddEventVC") as! AddEventVC
            //            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
