//
//  MainTabBarController.swift
//  FamilyFirst
//
//  Created by Lifeboat on 13/01/26.
//

import UIKit

class CustomTabBarController: UITabBarController,
                              UITabBarControllerDelegate,
                              UINavigationControllerDelegate {
    
    let circleButton = UIButton(type: .custom)
    let middleLabel = UILabel()
    let homeIndex = 2
    let gapOffset: CGFloat = 10
    
    private var tabBarShapeLayer: CAShapeLayer?
    private var customTabBarView: UIView!
    private var tabButtons: [UIButton] = []
    
    private var isTabBarSetup = false
    
    let tabBarBottomMargin: CGFloat = 0
    let tabBarCustomHeight: CGFloat = 60
    
    let tabItems: [(icon: String, title: String)] = [
        ("tab1", "FAMILY"),
        ("tab2", "LEARN"),
        ("", ""),
        ("tab4", "EDUTAIN"),
        ("tab5", "FEELS")
    ]
    
    let selectedColor = UIColor(red: 7/255.0, green: 104/255.0, blue: 57/255.0, alpha: 1.0)   // #076839 (Dark Green)
    let unselectedColor = UIColor(red: 141/255.0, green: 179/255.0, blue: 158/255.0, alpha: 1.0) // #8DB39E
    
    // var isSchoolUser = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        // ✅ Hide native tab bar completely
        hideNativeTabBar()
        
        if !isTabBarSetup {
            setupCustomTabBar()
            setupCircleButton()
            setupMiddleLabel()
            isTabBarSetup = true
        }
        
        for vc in viewControllers ?? [] {
            if let nav = vc as? UINavigationController {
                nav.delegate = self
            }
        }
        
        // updateMiddleTabTitleAndImage()
        updateTabSelection()
        
        // ✅ Start on the 3rd tab (Home)
        selectedIndex = homeIndex
    }
    
    // ✅ Properly hide native tab bar
    func hideNativeTabBar() {
        tabBar.isHidden = true
        tabBar.alpha = 0
        tabBar.frame = CGRect.zero
        tabBar.isUserInteractionEnabled = false
        
        // ✅ Move it off screen
        tabBar.frame.origin.y = UIScreen.main.bounds.height + 100
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNativeTabBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        hideNativeTabBar()
        positionCustomTabBar()
        positionCircle()
        positionMiddleLabel()
        updateVisibilityBasedOnDepth()
        bringTabBarToFront()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        hideNativeTabBar()
        positionCustomTabBar()
        positionCircle()
        positionMiddleLabel()
    }
    
    func setupCustomTabBar() {
        customTabBarView?.removeFromSuperview()
        
        customTabBarView = UIView()
        customTabBarView.backgroundColor = .clear
        customTabBarView.tag = 999
        view.addSubview(customTabBarView)
        
        addTabBarShape()
        createTabButtons()
    }
    
    func positionCustomTabBar() {
        guard customTabBarView != nil, customTabBarView.superview != nil else { return }
        
        let bottomInset = view.safeAreaInsets.bottom
        customTabBarView.frame = CGRect(
            x: 0,
            y: view.bounds.height - tabBarCustomHeight - tabBarBottomMargin - bottomInset,
            width: view.bounds.width,
            height: tabBarCustomHeight
        )
        
        addTabBarShape()
        positionTabButtons()
    }
    
    func createTabButtons() {
        tabButtons.forEach { $0.removeFromSuperview() }
        tabButtons.removeAll()
        
        for (index, item) in tabItems.enumerated() {
            if index == homeIndex {
                let emptyButton = UIButton()
                emptyButton.isUserInteractionEnabled = false
                tabButtons.append(emptyButton)
                continue
            }
            
            let button = createTabButton(
                icon: item.icon,
                title: item.title,
                tag: index
            )
            customTabBarView.addSubview(button)
            tabButtons.append(button)
        }
    }
    
    func createTabButton(icon: String, title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.tag = tag
        button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 4
        stackView.isUserInteractionEnabled = false
        
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage(named: icon)?.withRenderingMode(.alwaysTemplate)
        iconImageView.tintColor = unselectedColor
        iconImageView.tag = 100
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        titleLabel.textColor = unselectedColor
        titleLabel.textAlignment = .center
        titleLabel.tag = 101
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7
        
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        
        button.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: button.leadingAnchor, constant: 2),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: button.trailingAnchor, constant: -2)
        ])
        
        return button
    }
    
    func positionTabButtons() {
        let buttonWidth = view.bounds.width / CGFloat(tabItems.count)
        let buttonHeight = tabBarCustomHeight
        
        for (index, button) in tabButtons.enumerated() {
            if index == homeIndex { continue }
            
            button.frame = CGRect(
                x: CGFloat(index) * buttonWidth,
                y: 0,
                width: buttonWidth,
                height: buttonHeight
            )
        }
    }
    
    @objc func tabButtonTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        updateTabSelection()
        
        if let nav = viewControllers?[sender.tag] as? UINavigationController {
            nav.popToRootViewController(animated: false)
        }
        
        circleButton.layer.borderColor = UIColor.clear.cgColor
    }
    
    func updateTabSelection() {
        for (index, button) in tabButtons.enumerated() {
            if index == homeIndex { continue }
            
            let isSelected = (index == selectedIndex)
            
            if let stackView = button.subviews.first(where: { $0 is UIStackView }) as? UIStackView {
                if let iconView = stackView.arrangedSubviews.first as? UIImageView {
                    iconView.tintColor = isSelected ? selectedColor : unselectedColor
                }
                
                if let label = stackView.arrangedSubviews.last as? UILabel {
                    label.textColor = isSelected ? selectedColor : unselectedColor
                    label.font = UIFont.systemFont(ofSize: 10, weight: isSelected ? .semibold : .medium)
                }
            }
        }
        
        if selectedIndex == homeIndex {
            circleButton.layer.borderColor = selectedColor.cgColor
            middleLabel.textColor = selectedColor
            middleLabel.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        } else {
            circleButton.layer.borderColor = UIColor.clear.cgColor
            middleLabel.textColor = unselectedColor
            middleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        }
    }
    
    func addTabBarShape() {
        tabBarShapeLayer?.removeFromSuperlayer()
        
        guard customTabBarView != nil else { return }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createDipPath()
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.shadowOpacity = 0.15
        shapeLayer.shadowRadius = 16
        shapeLayer.shadowOffset = CGSize(width: 0, height: -4)
        shapeLayer.shadowColor = UIColor.black.cgColor
        
        customTabBarView.layer.insertSublayer(shapeLayer, at: 0)
        tabBarShapeLayer = shapeLayer
    }
    
    func createDipPath() -> CGPath {
        let w = view.bounds.width
        let h: CGFloat = tabBarCustomHeight
        let mid = w / 2
        let r: CGFloat = 24
        let dipW: CGFloat = w * 0.26
        let dipD: CGFloat = 26
        
        let p = UIBezierPath()
        
        p.move(to: CGPoint(x: r, y: 0))
        p.addQuadCurve(to: CGPoint(x: 0, y: r), controlPoint: CGPoint(x: 0, y: 0))
        p.addLine(to: CGPoint(x: 0, y: h - r))
        p.addQuadCurve(to: CGPoint(x: r, y: h), controlPoint: CGPoint(x: 0, y: h))
        p.addLine(to: CGPoint(x: w - r, y: h))
        p.addQuadCurve(to: CGPoint(x: w, y: h - r), controlPoint: CGPoint(x: w, y: h))
        p.addLine(to: CGPoint(x: w, y: r))
        p.addQuadCurve(to: CGPoint(x: w - r, y: 0), controlPoint: CGPoint(x: w, y: 0))
        
        let dipStart = mid + dipW / 2
        let dipEnd = mid - dipW / 2
        
        p.addLine(to: CGPoint(x: dipStart, y: 0))
        p.addQuadCurve(to: CGPoint(x: mid, y: dipD), controlPoint: CGPoint(x: mid + dipW / 4, y: dipD))
        p.addQuadCurve(to: CGPoint(x: dipEnd, y: 0), controlPoint: CGPoint(x: mid - dipW / 4, y: dipD))
        p.addLine(to: CGPoint(x: r, y: 0))
        p.close()
        
        return p.cgPath
    }
    
    func bringTabBarToFront() {
        if customTabBarView != nil {
            view.bringSubviewToFront(customTabBarView)
        }
        view.bringSubviewToFront(circleButton)
    }
    
    func setupCircleButton() {
        circleButton.removeFromSuperview()
        
        let size: CGFloat = 60
        circleButton.frame = CGRect(x: 0, y: 0, width: size, height: size)
        circleButton.layer.cornerRadius = size / 2
        circleButton.backgroundColor = .white
        circleButton.tag = 998
        
        circleButton.setImage(UIImage(named: "tab3"), for: .normal)
        circleButton.imageView?.contentMode = .scaleAspectFit
        circleButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        circleButton.layer.borderWidth = 1
        circleButton.layer.borderColor = UIColor.clear.cgColor
        
        circleButton.layer.shadowOpacity = 0.25
        circleButton.layer.shadowRadius = 10
        circleButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        circleButton.layer.shadowColor = UIColor.black.cgColor
        
        circleButton.removeTarget(nil, action: nil, for: .allEvents)
        circleButton.addTarget(self, action: #selector(circleTapped), for: .touchUpInside)
        
        view.addSubview(circleButton)
        view.bringSubviewToFront(circleButton)
    }
    
    func setupMiddleLabel() {
        middleLabel.removeFromSuperview()
        
        middleLabel.text = "EXPLORE"
        middleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        middleLabel.textColor = unselectedColor
        middleLabel.textAlignment = .center
        middleLabel.adjustsFontSizeToFitWidth = true
        middleLabel.minimumScaleFactor = 0.7
        middleLabel.tag = 997
        
        customTabBarView.addSubview(middleLabel)
    }
    
    func positionMiddleLabel() {
        guard customTabBarView != nil else { return }
        
        let labelWidth: CGFloat = 80
        let labelHeight: CGFloat = 14
        
        middleLabel.frame = CGRect(
            x: (view.bounds.width - labelWidth) / 2,
            y: tabBarCustomHeight - labelHeight - 8,
            width: labelWidth,
            height: labelHeight
        )
    }
    
    func positionCircle() {
        guard customTabBarView != nil else { return }
        
        let tabFrame = customTabBarView.frame
        let circleHalf = circleButton.bounds.height / 2

        circleButton.center = CGPoint(
            x: tabFrame.midX,
            y: tabFrame.minY - circleHalf + gapOffset
        )
        
        view.bringSubviewToFront(circleButton)
    }
    
    @objc func circleTapped() {
        selectedIndex = homeIndex
        updateTabSelection()
        
        if let nav = viewControllers?[homeIndex] as? UINavigationController {
            nav.popToRootViewController(animated: false)
        }
        
        circleButton.layer.borderColor = selectedColor.cgColor
    }
    
    func updateVisibilityBasedOnDepth() {
        guard let nav = viewControllers?[selectedIndex] as? UINavigationController else { return }
        
        let isRoot = (nav.viewControllers.count == 1)
        
        customTabBarView?.isHidden = !isRoot
        circleButton.isHidden = !isRoot
        middleLabel.isHidden = !isRoot
        circleButton.alpha = isRoot ? 1 : 0
        circleButton.isUserInteractionEnabled = isRoot
        
        // ✅ ALWAYS keep native tab bar hidden
        hideNativeTabBar()
    }
    
    override var selectedIndex: Int {
        didSet {
            updateTabSelection()
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
        updateTabSelection()
        updateVisibilityBasedOnDepth()
        hideNativeTabBar()
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        DispatchQueue.main.async {
            self.updateVisibilityBasedOnDepth()
            self.hideNativeTabBar()
        }
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        updateVisibilityBasedOnDepth()
        hideNativeTabBar()
    }
}
