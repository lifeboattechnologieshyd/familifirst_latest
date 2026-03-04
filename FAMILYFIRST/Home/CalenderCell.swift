//
//  CalenderCell.swift
//  FamilyFirst
//
//  Created by Lifeboat on 10/01/26.
//

import UIKit

class CalenderCell: UITableViewCell {

    @IBOutlet weak var viewallBtn: UIButton!
    @IBOutlet weak var colVw: UICollectionView!
    
    // Empty state views (created programmatically)
    private var emptyStateView: UIView?
    private var emptyStateLabel: UILabel?
    private var emptyStateImageView: UIImageView?
    
    var didTapViewAll: (() -> Void)?
    var didSelectCalenderItem: ((Int) -> Void)?
    
    var events: [Event] = [] {
        didSet {
            colVw.reloadData()
            updateEmptyState()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        colVw.delegate = self
        colVw.dataSource = self
        
        let nib = UINib(nibName: "CalenderCollectionCell", bundle: nil)
        colVw.register(nib, forCellWithReuseIdentifier: "CalenderCollectionCell")
        
        setupEmptyStateView()
        
        colVw.reloadData()
        
        viewallBtn.addTarget(self, action: #selector(viewAllBtnTapped), for: .touchUpInside)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        didTapViewAll = nil
        didSelectCalenderItem = nil
        events = []
    }
    
    
    private func setupEmptyStateView() {
        // Create container view
        emptyStateView = UIView()
        emptyStateView?.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView?.isHidden = true
        
        guard let emptyStateView = emptyStateView else { return }
        
        // Add to content view
        contentView.addSubview(emptyStateView)
        
        // Constraints for empty state view (same position as collection view)
        NSLayoutConstraint.activate([
            emptyStateView.leadingAnchor.constraint(equalTo: colVw.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: colVw.trailingAnchor),
            emptyStateView.topAnchor.constraint(equalTo: colVw.topAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: colVw.bottomAnchor)
        ])
        
        // Create horizontal stack for icon + text
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        emptyStateView.addSubview(stackView)
        
        // Center stack in empty state view
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: emptyStateView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: emptyStateView.trailingAnchor, constant: -16)
        ])
        
        // Create calendar icon
        emptyStateImageView = UIImageView()
        emptyStateImageView?.image = UIImage(systemName: "calendar.badge.plus")
        emptyStateImageView?.tintColor = .systemGray3
        emptyStateImageView?.contentMode = .scaleAspectFit
        emptyStateImageView?.translatesAutoresizingMaskIntoConstraints = false
        
        if let imageView = emptyStateImageView {
            stackView.addArrangedSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 32),
                imageView.heightAnchor.constraint(equalToConstant: 32)
            ])
        }
        
        // Create label
        emptyStateLabel = UILabel()
        emptyStateLabel?.text = "No upcoming events"
        emptyStateLabel?.textColor = .systemGray
        emptyStateLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        emptyStateLabel?.textAlignment = .left
        emptyStateLabel?.translatesAutoresizingMaskIntoConstraints = false
        
        if let label = emptyStateLabel {
            stackView.addArrangedSubview(label)
        }
    }
    
    
    private func updateEmptyState() {
        if events.isEmpty {
            colVw.isHidden = true
            emptyStateView?.isHidden = false
        } else {
            colVw.isHidden = false
            emptyStateView?.isHidden = true
        }
    }
    
    @objc private func viewAllBtnTapped() {
        didTapViewAll?()
    }
}

extension CalenderCell: UICollectionViewDelegate,
                        UICollectionViewDataSource,
                        UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return min(events.count, 7)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CalenderCollectionCell",
            for: indexPath
        ) as! CalenderCollectionCell
        
        if indexPath.item < events.count {
            let event = events[indexPath.item]
            cell.configure(with: event)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 196, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        didSelectCalenderItem?(indexPath.item)
    }
}
