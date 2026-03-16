//
//  SelectCurriculumVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 08/11/25.
//

import UIKit

class SelectCurriculumVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tblVw: UITableView!
    
    var types = [Curriculum]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📱 SelectCurriculumVC - viewDidLoad")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        // ── Register Cell ───────────────────────────────
        print("📋 Registering CurriculumTypeCell nib...")
        self.tblVw.register(UINib(nibName: "CurriculumTypeCell", bundle: nil), forCellReuseIdentifier: "CurriculumTypeCell")
        
        self.tblVw.delegate = self
        self.tblVw.dataSource = self
        print("✅ TableView delegate & dataSource set")
        
        // ── Fetch Data ──────────────────────────────────
        self.getCurriculumType()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        print("⬅️ Back button tapped")
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("📋 numberOfRowsInSection: \(types.count)")
        return types.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("📋 cellForRowAt: \(indexPath.row)")
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CurriculumTypeCell") as? CurriculumTypeCell else {
            print("❌ Failed to dequeue CurriculumTypeCell at row \(indexPath.row)!")
            return UITableViewCell()
        }
        
        let curriculum = types[indexPath.row]
        print("   Name: \(curriculum.curriculumName ?? "nil")")
        print("   Description: \(String(describing: curriculum.description?.prefix(50) ?? "nil"))")
        
        cell.lblDesc.text = curriculum.description
        cell.lblName.text = curriculum.curriculumName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCurriculum = types[indexPath.row]
        
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("👆 Row selected: \(indexPath.row)")
        print("   Curriculum Name: \(selectedCurriculum.curriculumName ?? "nil")")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        guard let vc = storyboard?.instantiateViewController(identifier: "AssessmentsGradeSelectionVC") as? AssessmentsGradeSelectionVC else {
            print("❌ Failed to instantiate AssessmentsGradeSelectionVC!")
            return
        }
        
        print("✅ Pushing to AssessmentsGradeSelectionVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - API Call
    
    func getCurriculumType() {
        let urlString = API.CURRICULUM_TYPES
        
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🌐 getCurriculumType() called")
        print("🌐 URL: \(urlString)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        showLoader()
        
        NetworkManager.shared.request(urlString: urlString, method: .GET) { (result: Result<APIResponse<[Curriculum]>, NetworkError>) in
            
            print("📥 getCurriculumType response received")
            
            switch result {
            case .success(let info):
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("✅ API Response:")
                print("   success: \(info.success)")
                print("   errorCode: \(info.errorCode)")
                print("   description: \(info.description)")
                print("   total: \(String(describing: info.total))")
                print("   data count: \(info.data?.count ?? 0)")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                
                if info.success {
                    if let data = info.data {
                        self.types = data
                        
                        print("📋 Curriculum Types loaded:")
                        for (index, curriculum) in data.enumerated() {
                            print("   [\(index)] \(curriculum.curriculumName ?? "nil")")
                        }
                    } else {
                        print("⚠️ info.data is nil!")
                    }
                    
                    DispatchQueue.main.async {
                        self.tblVw.reloadData()
                        self.hideLoader()
                        print("✅ TableView reloaded with \(self.types.count) items")
                    }
                } else {
                    print("❌ API returned success = false")
                    print("❌ Description: \(info.description)")
                    
                    DispatchQueue.main.async {
                        self.hideLoader()
                        self.showAlert(msg: info.description)
                    }
                }
                
            case .failure(let error):
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("❌ Network FAILED!")
                print("❌ Error: \(error)")
                print("❌ Localized: \(error.localizedDescription)")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                
                DispatchQueue.main.async {
                    self.hideLoader()
                    self.showAlert(msg: error.localizedDescription)
                }
            }
        }
    }
}
