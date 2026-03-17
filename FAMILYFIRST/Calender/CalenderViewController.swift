//
//  CalenderViewController.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 07/03/26.
//

import UIKit

class CalenderViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var dateSelectionView: MonthHeaderView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var colVw: UICollectionView!
    
    // MARK: - Properties
    var selectedIndex: IndexPath?
    var calender: [CalendarData] = []
    var allCalendarData: [CalendarData] = []
    
    // IMPORTANT: Separate baseDate and selectedDate
    var baseDate: Date = Date()           // Used for calculating week dates (center date)
    var currentSelectedDate: Date = Date() // The actual selected date for filtering
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTableView()
        setupHeaderView()
        loadInitialData()
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Setup
    
    private func setupHeaderView() {
        dateSelectionView.currentDate = baseDate
        
        dateSelectionView.onDateChanged = { [weak self] newDate in
            guard let self = self else { return }
            
            // Update base date to new month's date
            self.baseDate = newDate
            self.currentSelectedDate = newDate
            
            // Reset selection to center (index 3)
            self.selectedIndex = IndexPath(row: 3, section: 0)
            
            // Reload collection view and filter data
            self.colVw.reloadData()
            self.filterCalendarForCurrentDate()
        }
    }
    
    private func setupCollectionView() {
        colVw.register(UINib(nibName: "DateCell", bundle: nil), forCellWithReuseIdentifier: "DateCell")
        colVw.delegate = self
        colVw.dataSource = self
    }
    
    private func setupTableView() {
        let calendarNib = UINib(nibName: "CalendarTableCell", bundle: nil)
        tblVw.register(calendarNib, forCellReuseIdentifier: "CalendarTableCell")
        
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.separatorStyle = .none
        tblVw.rowHeight = UITableView.automaticDimension
        tblVw.estimatedRowHeight = 100
    }
    
    private func loadInitialData() {
        // Set initial selected index to center (today)
        selectedIndex = IndexPath(row: 3, section: 0)
        
        // Both baseDate and currentSelectedDate start as today
        baseDate = Date()
        currentSelectedDate = Date()
        
        // Fetch calendar data
        fetchCalenderData()
    }
    
    // MARK: - Helper Methods
    
    private func getDate(for index: Int) -> Date {
        let calendar = Calendar.current
        let offset = index - 3
        // IMPORTANT: Use baseDate here, NOT currentSelectedDate
        return calendar.date(byAdding: .day, value: offset, to: baseDate) ?? baseDate
    }
    
    // MARK: - Data Fetching
    
    private func fetchCalenderData() {
        if !allCalendarData.isEmpty {
            filterCalendarForCurrentDate()
            return
        }
        
        showLoader()
        
        NetworkManager.shared.request(
            urlString: API.BROADCAST_CALENDAR,
            method: .GET
        ) { [weak self] (result: Result<APIResponse<[CalendarData]>, NetworkError>) in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.hideLoader()
                
                switch result {
                case .success(let response):
                    if response.success, let allData = response.data {
                        self.allCalendarData = allData
                        self.filterCalendarForCurrentDate()
                    } else {
                        self.calender = []
                        self.tblVw.reloadData()
                    }
                    
                case .failure(_):
                    self.calender = []
                    self.tblVw.reloadData()
                    self.showAlert(msg: "Failed to load calendar data")
                }
            }
        }
    }
    
    private func filterCalendarForCurrentDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let dateString = dateFormatter.string(from: currentSelectedDate)
        
        calender = allCalendarData.filter { $0.date == dateString }
        tblVw.reloadData()
    }
}

// MARK: - UICollectionViewDelegate & DataSource

extension CalenderViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
        
        let date = getDate(for: indexPath.item)
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"
        monthFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        dayFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        cell.lblMonth.text = monthFormatter.string(from: date)
        cell.lblDay.text = dayFormatter.string(from: date)
        cell.lblDate.text = dateFormatter.string(from: date)
        
        // Only update UI - NO data fetching here
        if indexPath == selectedIndex {
            cell.bgView.backgroundColor = UIColor(red: 7/255, green: 104/255, blue: 57/255, alpha: 1)
            cell.lblMonth.textColor = .white
            cell.lblDay.textColor = .white
            cell.lblDate.textColor = .white
        } else {
            cell.bgView.backgroundColor = UIColor(red: 237/255, green: 246/255, blue: 255/255, alpha: 1)
            cell.lblMonth.textColor = .darkGray
            cell.lblDay.textColor = .darkGray
            cell.lblDate.textColor = .black
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Avoid re-selecting same cell
        guard selectedIndex != indexPath else { return }
        
        // Store old index for partial reload
        let oldSelectedIndex = selectedIndex
        selectedIndex = indexPath
        
        // Update the selected date (NOT baseDate!)
        currentSelectedDate = getDate(for: indexPath.item)
        
        // Reload only affected cells for smooth animation
        var indexPathsToReload: [IndexPath] = [indexPath]
        if let oldIndex = oldSelectedIndex {
            indexPathsToReload.append(oldIndex)
        }
        
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: indexPathsToReload)
        }
        
        // Filter data for newly selected date
        filterCalendarForCurrentDate()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 7
        return CGSize(width: width, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - UITableViewDelegate & DataSource

extension CalenderViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calender.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarTableCell", for: indexPath) as! CalendarTableCell
        
        if indexPath.row < calender.count {
            cell.configure(calendarData: calender[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !calender.isEmpty else { return nil }
        
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Today's Activity"
        
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return calender.isEmpty ? 0 : 44
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard calender.isEmpty else { return nil }
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 200))
        footerView.backgroundColor = .clear
        
        let messageLabel = UILabel()
        messageLabel.text = "📅\n\nNo activities scheduled for this date.\n\nTry selecting another date."
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        messageLabel.textColor = .secondaryLabel
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        footerView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 40),
            messageLabel.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -40)
        ])
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return calender.isEmpty ? 200 : 0
    }
}
