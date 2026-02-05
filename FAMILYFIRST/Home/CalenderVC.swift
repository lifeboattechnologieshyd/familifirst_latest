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
    
    private var allEvents: [Event] = []
    private var upcomingMonthlyEvents: [MonthEventsGroup] = []
    private var completedMonthlyEvents: [MonthEventsGroup] = []
    
    private var upcomingUnderlineView: UIView!
    private var completedUnderlineView: UIView!
    
    enum EventTab {
        case upcoming
        case completed
    }
    
    private var currentTab: EventTab = .upcoming
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        topVw.addBottomShadow()
        
        setupTableView()
        setupButtons()
        setupUnderlineViews()
        updateTabUI()
        fetchEvents()
    }
    
    private func setupTableView() {
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.separatorStyle = .none
        
        tblVw.register(UINib(nibName: "MonthCell", bundle: nil), forCellReuseIdentifier: "MonthCell")
        tblVw.register(UINib(nibName: "AddEventCell", bundle: nil), forCellReuseIdentifier: "AddEventCell")
    }
    
    private func setupButtons() {
        upcomingBtn.addTarget(self, action: #selector(upcomingBtnTapped), for: .touchUpInside)
        completedBtn.addTarget(self, action: #selector(completedBtnTapped), for: .touchUpInside)
    }
    
    private func setupUnderlineViews() {
        upcomingUnderlineView = UIView()
        upcomingUnderlineView.backgroundColor = UIColor(hex: "#076839")
        upcomingUnderlineView.translatesAutoresizingMaskIntoConstraints = false
        upcomingBtn.addSubview(upcomingUnderlineView)
        
        NSLayoutConstraint.activate([
            upcomingUnderlineView.leadingAnchor.constraint(equalTo: upcomingBtn.leadingAnchor),
            upcomingUnderlineView.trailingAnchor.constraint(equalTo: upcomingBtn.trailingAnchor),
            upcomingUnderlineView.bottomAnchor.constraint(equalTo: upcomingBtn.bottomAnchor),
            upcomingUnderlineView.heightAnchor.constraint(equalToConstant: 3)
        ])
        
        completedUnderlineView = UIView()
        completedUnderlineView.backgroundColor = UIColor(hex: "#076839")
        completedUnderlineView.translatesAutoresizingMaskIntoConstraints = false
        completedBtn.addSubview(completedUnderlineView)
        
        NSLayoutConstraint.activate([
            completedUnderlineView.leadingAnchor.constraint(equalTo: completedBtn.leadingAnchor),
            completedUnderlineView.trailingAnchor.constraint(equalTo: completedBtn.trailingAnchor),
            completedUnderlineView.bottomAnchor.constraint(equalTo: completedBtn.bottomAnchor),
            completedUnderlineView.heightAnchor.constraint(equalToConstant: 3)
        ])
    }
    
    @objc private func upcomingBtnTapped() {
        guard currentTab != .upcoming else { return }
        currentTab = .upcoming
        updateTabUI()
        tblVw.reloadData()
    }
    
    @objc private func completedBtnTapped() {
        guard currentTab != .completed else { return }
        currentTab = .completed
        updateTabUI()
        tblVw.reloadData()
    }
    
    private func updateTabUI() {
        UIView.animate(withDuration: 0.3) {
            switch self.currentTab {
            case .upcoming:
                self.upcomingBtn.setTitleColor(UIColor(hex: "#076839"), for: .normal)
                self.upcomingBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
                self.upcomingUnderlineView.alpha = 1.0
                
                self.completedBtn.setTitleColor(UIColor(hex: "#8DB39E"), for: .normal)
                self.completedBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
                self.completedUnderlineView.alpha = 0.0
                
            case .completed:
                self.completedBtn.setTitleColor(UIColor(hex: "#076839"), for: .normal)
                self.completedBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
                self.completedUnderlineView.alpha = 1.0
                
                self.upcomingBtn.setTitleColor(UIColor(hex: "#8DB39E"), for: .normal)
                self.upcomingBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
                self.upcomingUnderlineView.alpha = 0.0
            }
        }
    }
    
    private func fetchEvents() {
        guard let userId = UserManager.shared.userId else { return }
        
        let urlString = "\(API.GET_EVENTS)?event_users=\(userId)"
        
        NetworkManager.shared.request(
            urlString: urlString,
            method: .GET
        ) { [weak self] (result: Result<APIResponse<[Event]>, NetworkError>) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success, let events = response.data {
                        self?.allEvents = events
                        self?.separateEvents(events)
                        self?.tblVw.reloadData()
                    }
                case .failure(let error):
                    print("Error fetching events: \(error)")
                }
            }
        }
    }
    
    private func separateEvents(_ events: [Event]) {
        let now = Date()
        
        let upcoming = events.filter { ($0.eventDate ?? Date()) >= now }
            .sorted { ($0.eventDate ?? Date()) < ($1.eventDate ?? Date()) }
        
        let completed = events.filter { ($0.eventDate ?? Date()) < now }
            .sorted { ($0.eventDate ?? Date()) > ($1.eventDate ?? Date()) }
        
        upcomingMonthlyEvents = groupEventsByMonth(upcoming)
        completedMonthlyEvents = groupEventsByMonth(completed)
    }
    
    private func groupEventsByMonth(_ events: [Event]) -> [MonthEventsGroup] {
        var grouped: [String: [Event]] = [:]
        var sortDates: [String: Date] = [:]
        var monthNames: [String: String] = [:]
        
        for event in events {
            let key = event.monthYearKey
            if grouped[key] == nil {
                grouped[key] = []
            }
            grouped[key]?.append(event)
            
            if sortDates[key] == nil, let date = event.eventDate {
                sortDates[key] = date
            }
            
            if monthNames[key] == nil {
                monthNames[key] = event.monthOnlyKey
            }
        }
        
        return grouped.map { (key, events) in
            MonthEventsGroup(
                monthYear: key,
                monthOnly: monthNames[key] ?? key,
                events: events.sorted { ($0.eventDate ?? Date()) < ($1.eventDate ?? Date()) },
                sortOrder: sortDates[key] ?? Date()
            )
        }.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    private func currentMonthlyEvents() -> [MonthEventsGroup] {
        switch currentTab {
        case .upcoming:
            return upcomingMonthlyEvents
        case .completed:
            return completedMonthlyEvents
        }
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func navigateToCreateEventVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "CreateEventVC") as? CreateEventVC else { return }
        vc.onEventCreated = { [weak self] in
            self?.fetchEvents()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CalenderVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return currentMonthlyEvents().count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let monthlyEvents = currentMonthlyEvents()
        
        if section < monthlyEvents.count {
            return monthlyEvents[section].events.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let monthlyEvents = currentMonthlyEvents()
        
        if indexPath.section < monthlyEvents.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MonthCell", for: indexPath) as! MonthCell
            let event = monthlyEvents[indexPath.section].events[indexPath.row]
            cell.configure(with: event)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddEventCell", for: indexPath) as! AddEventCell
            cell.onAddEventTapped = { [weak self] in
                self?.navigateToCreateEventVC()
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let monthlyEvents = currentMonthlyEvents()
        
        if section < monthlyEvents.count {
            let headerView = UIView()
            headerView.backgroundColor = .clear
            
            let lineColor = UIColor(hex: "#CDE1D7") ?? .lightGray
            
            let leftLine = UIView()
            leftLine.backgroundColor = lineColor
            leftLine.translatesAutoresizingMaskIntoConstraints = false
            
            let rightLine = UIView()
            rightLine.backgroundColor = lineColor
            rightLine.translatesAutoresizingMaskIntoConstraints = false
            
            let monthLabel = UILabel()
            monthLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            monthLabel.textColor = .darkGray
            monthLabel.textAlignment = .center
            monthLabel.translatesAutoresizingMaskIntoConstraints = false
            
            monthLabel.text = monthlyEvents[section].monthOnly.uppercased()
            
            headerView.addSubview(leftLine)
            headerView.addSubview(monthLabel)
            headerView.addSubview(rightLine)
            
            NSLayoutConstraint.activate([
                leftLine.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                leftLine.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                leftLine.heightAnchor.constraint(equalToConstant: 1),
                leftLine.trailingAnchor.constraint(equalTo: monthLabel.leadingAnchor, constant: -12),
                
                monthLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
                monthLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                
                rightLine.leadingAnchor.constraint(equalTo: monthLabel.trailingAnchor, constant: 12),
                rightLine.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                rightLine.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                rightLine.heightAnchor.constraint(equalToConstant: 1)
            ])
            
            return headerView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let monthlyEvents = currentMonthlyEvents()
        
        if section < monthlyEvents.count {
            return 40
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let monthlyEvents = currentMonthlyEvents()
        
        if indexPath.section < monthlyEvents.count {
            return 76
        } else {
            return 42
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let monthlyEvents = currentMonthlyEvents()
        
        if indexPath.section < monthlyEvents.count {
            let event = monthlyEvents[indexPath.section].events[indexPath.row]
            print("Selected event: \(event.eventName)")
        }
    }
}
