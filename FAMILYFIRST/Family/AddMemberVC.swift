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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        topVw.addBottomShadow()
        self.navigationItem.hidesBackButton = true

    }

    private func setupTableView() {
        tblVw.delegate = self
        tblVw.dataSource = self
        

        tblVw.register(
            UINib(nibName: "AddFamilyMemberCell", bundle: nil),
            forCellReuseIdentifier: "AddFamilyMemberCell"
        )

    }
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension AddMemberVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "AddFamilyMemberCell",
            for: indexPath
        ) as! AddFamilyMemberCell

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 670
    }
}
