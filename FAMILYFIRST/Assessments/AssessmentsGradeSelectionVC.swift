import UIKit

class AssessmentsGradeSelectionVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var completedAssessments: UIButton!
    @IBOutlet weak var colVw: UICollectionView!
    @IBOutlet weak var colVwHeightConstraint: NSLayoutConstraint! 
    
    // MARK: - Properties
    var grades = [GradeModel]()
    
    // MARK: - Pagination Properties
    var currentPage: Int = 1
    var totalGrades: Int = 0
    var isLoading: Bool = false
    let pageSize: Int = 10
    
    // ✅ Cell dimensions
    let cellHeight: CGFloat = 32
    let cellSpacing: CGFloat = 10
    let itemsPerRow: CGFloat = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        getGrades()
    }
    
    private func setupCollectionView() {
        colVw.register(UINib(nibName: "GradeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "GradeCollectionCell")
        colVw.delegate = self
        colVw.dataSource = self
        colVw.isScrollEnabled = true
    }
    
    // ✅ Update CollectionView height based on number of grades
    private func updateCollectionViewHeight() {
        let numberOfRows = ceil(CGFloat(grades.count) / itemsPerRow)
        let totalHeight = (numberOfRows * cellHeight) + ((numberOfRows - 1) * cellSpacing) + 20 // +20 for padding
        
        colVwHeightConstraint.constant = totalHeight
        view.layoutIfNeeded()
        
        print("📐 Rows: \(Int(numberOfRows)), Height: \(totalHeight)")
    }
    
    @IBAction func onClickCompleted(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(identifier: "PastAssessmentsVC") as! PastAssessmentsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Fetch Grades with Pagination
    
    func getGrades() {
        guard let userId = UserManager.shared.userId else {
            print("❌ Error: userId not found in UserManager")
            self.showAlert(msg: "User ID not found. Please login again.")
            return
        }
        
        guard !isLoading else { return }
        
        isLoading = true
        
        if currentPage == 1 {
            showLoader()
        }
        
        print("📱 Fetching grades: Page \(currentPage), PageSize \(pageSize)")
        
        let urlString = "\(API.VOCABEE_GET_GRADES)?user_id=\(userId)&page=\(currentPage)&page_size=\(pageSize)"
        
        NetworkManager.shared.request(urlString: urlString, method: .GET) { (result: Result<APIResponse<[GradeModel]>, NetworkError>) in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let info):
                    if info.success {
                        if let data = info.data {
                            if let total = info.total {
                                self.totalGrades = total
                            }
                            
                            self.grades.append(contentsOf: data)
                            self.grades = self.removeDuplicates(from: self.grades)
                            
                            self.grades.sort {
                                if $0.numericGrade == $1.numericGrade {
                                    return $0.name < $1.name
                                }
                                return $0.numericGrade < $1.numericGrade
                            }
                            
                            print("✅ Page \(self.currentPage): Loaded \(self.grades.count) of \(self.totalGrades) grades")
                            
                            if self.grades.count < self.totalGrades && data.count > 0 {
                                self.currentPage += 1
                                self.getGrades()
                            } else {
                                self.hideLoader()
                                
                                // ✅ Update height and reload
                                self.updateCollectionViewHeight()
                                self.colVw.reloadData()
                                
                                print("✅ All \(self.grades.count) grades loaded!")
                                print("📋 Grades: \(self.grades.map { $0.name })")
                            }
                        } else {
                            self.hideLoader()
                            self.showAlert(msg: "No grades available")
                        }
                    } else {
                        self.hideLoader()
                        self.showAlert(msg: info.description ?? "Failed to load grades")
                    }
                    
                case .failure(let error):
                    self.hideLoader()
                    switch error {
                    case .noaccess:
                        self.performLogout()
                    default:
                        self.showAlert(msg: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func removeDuplicates(from grades: [GradeModel]) -> [GradeModel] {
        var seen = Set<String>()
        return grades.filter { grade in
            if seen.contains(grade.id) {
                return false
            } else {
                seen.insert(grade.id)
                return true
            }
        }
    }
    
    func performLogout() {
        UserManager.shared.logout()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
            let navController = UINavigationController(rootViewController: loginVC)
            navController.modalPresentationStyle = .fullScreen
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = navController
                window.makeKeyAndVisible()
            }
        }
    }
}

// MARK: - UICollectionView Delegate & DataSource

extension AssessmentsGradeSelectionVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("🔢 Collection view showing \(grades.count) items")
        return grades.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GradeCollectionCell", for: indexPath) as! GradeCollectionCell
        cell.lblGrade.text = grades[indexPath.row].name
        cell.lblGrade.backgroundColor = .white
        print("📱 Cell \(indexPath.row): \(grades[indexPath.row].name)")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (colVw.frame.size.width - 32) / 3
        return CGSize(width: width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(identifier: "AssessmentSubjectSelectionVC") as? AssessmentSubjectSelectionVC else {
            return
        }
        vc.grade_id = grades[indexPath.row].id
        print("✅ Selected grade: \(grades[indexPath.row].name)")
        navigationController?.pushViewController(vc, animated: true)
    }
}
