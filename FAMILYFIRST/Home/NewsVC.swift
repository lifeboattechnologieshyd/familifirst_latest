//
//  NewsVC.swift
//  FamilyFirst
//
//  Created by Lifeboat on 13/01/26.
//

import UIKit

class NewsVC: UIViewController {

    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true

        tblVw.delegate = self
        tblVw.dataSource = self
        
        tblVw.register(UINib(nibName: "NewsCell", bundle: nil),forCellReuseIdentifier: "NewsCell")
     
    }
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
extension NewsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return tableView.dequeueReusableCell(withIdentifier: "NewsCell",for: indexPath) as! NewsCell
    }
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 790
    }
}
