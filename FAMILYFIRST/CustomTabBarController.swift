//
//  MainTabBarController.swift
//  FamilyFirst
//
//  Created by Lifeboat on 13/01/26.
//

import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    let circleButton = UIButton(type: .custom)
    let homeIndex = 2 // This is the 3rd tab (Index 0, 1, 2)
    let gapOffset: CGFloat = -10
    
    // ✅ Define Colors
    let selectedColor = UIColor(red: 7/255.0, green: 104/255.0, blue: 57/255.0, alpha: 1.0)   // #076839 (Dark Green)
    let unselectedColor = UIColor(red: 141/255.0, green: 179/255.0, blue: 158/255.0, alpha: 1.0) // #8DB39E

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        // Apply custom non-moving tab bar
        let fixedTabBar = UTabBarFixedDip()
        setValue(fixedTabBar, forKey: "tabBar")
        
        setupCircleButton()
        disableMiddleTabItem()
        setupTabColors()
        
        // Attach circle reference for hitTest
        if let dip = tabBar as? UTabBarFixedDip {
            dip.circleButtonRef = circleButton
        }
        
        // ✅ START ON THE 3RD TAB (Home)
        selectedIndex = homeIndex
        
        // Set initial border state (Highlight the circle immediately)
        updateCircleBorder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        positionCircle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        positionCircle()
        updateVisibilityBasedOnDepth()
    }
    
    // ------------------------------------------------------------
    // ✅ Setup Tab Bar Colors (Text & Icons)
    // ------------------------------------------------------------
    func setupTabColors() {
        // 1. Simple Tint (Legacy support)
        tabBar.tintColor = selectedColor
        tabBar.unselectedItemTintColor = unselectedColor
        
        // 2. Modern Appearance (iOS 15+)
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground() // We have a custom shape layer
        
        // Define attributes
        let normalAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: unselectedColor]
        let selectedAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: selectedColor]
        
        // Apply to standard tabs (Stacked)
        appearance.stackedLayoutAppearance.normal.iconColor = unselectedColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        
        // Apply to inline/compact (if ever used)
        appearance.inlineLayoutAppearance.normal.iconColor = unselectedColor
        appearance.inlineLayoutAppearance.normal.titleTextAttributes = normalAttributes
        
        appearance.inlineLayoutAppearance.selected.iconColor = selectedColor
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        
        // Set the appearance
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    // ------------------------------------------------------------
    // ✅ Disable the middle tab item
    // ------------------------------------------------------------
    func disableMiddleTabItem() {
        if let items = tabBar.items, items.count > homeIndex {
            items[homeIndex].isEnabled = false
            items[homeIndex].image = UIImage()
            items[homeIndex].selectedImage = UIImage()
        }
    }
    
    // ------------------------------------------------------------
    // ✅ Setup floating circle button
    // ------------------------------------------------------------
    func setupCircleButton() {
        let size: CGFloat = 62
        circleButton.frame = CGRect(x: 0, y: 0, width: size, height: size)
        circleButton.layer.cornerRadius = size / 2
        circleButton.backgroundColor = .white
        
        circleButton.setImage(UIImage(named: "tab3"), for: .normal)
        circleButton.imageView?.contentMode = .scaleAspectFit
        circleButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        // Default border setup
        circleButton.layer.borderWidth = 1
        circleButton.layer.borderColor = UIColor.clear.cgColor
        
        // Shadow
        circleButton.layer.shadowOpacity = 0.25
        circleButton.layer.shadowRadius = 10
        circleButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        circleButton.addTarget(self, action: #selector(circleTapped), for: .touchUpInside)
        
        tabBar.addSubview(circleButton)
        tabBar.bringSubviewToFront(circleButton)
    }
    
    func positionCircle() {
        circleButton.center = CGPoint(
            x: tabBar.bounds.midX,
            y: tabBar.bounds.minY + gapOffset
        )
    }
    
    // ------------------------------------------------------------
    // ✅ Update Circle Border (#076839)
    // ------------------------------------------------------------
    func updateCircleBorder() {
        if selectedIndex == homeIndex {
            // Highlighting Middle Tab with #076839
            circleButton.layer.borderColor = selectedColor.cgColor
        } else {
            circleButton.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    // ------------------------------------------------------------
    // ✅ Circle button tap
    // ------------------------------------------------------------
    @objc func circleTapped() {
        selectedIndex = homeIndex
        
        if let nav = viewControllers?[homeIndex] as? UINavigationController {
            nav.popToRootViewController(animated: false)
        }
        
        updateCircleBorder()
        updateVisibilityBasedOnDepth()
    }
    
    // ------------------------------------------------------------
    // ✅ Delegate: Tab Switching
    // ------------------------------------------------------------
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        updateCircleBorder()
        updateVisibilityBasedOnDepth()
    }
    
    // ------------------------------------------------------------
    // ✅ Visibility logic
    // ------------------------------------------------------------
    func updateVisibilityBasedOnDepth() {
        guard let nav = viewControllers?[selectedIndex] as? UINavigationController else { return }
        
        let isRoot = (nav.viewControllers.count == 1)
        
        if isRoot {
            tabBar.isHidden = false
            circleButton.isHidden = false
            circleButton.alpha = 1
            circleButton.isUserInteractionEnabled = true
        } else {
            tabBar.isHidden = true
            circleButton.isHidden = true
            circleButton.alpha = 0
            circleButton.isUserInteractionEnabled = false
        }
    }

    // ------------------------------------------------------------
    // ✅ Custom Shape Class
    // ------------------------------------------------------------
    class UTabBarFixedDip: UITabBar {
        
        var circleButtonRef: UIButton?
        private var shapeLayer: CAShapeLayer?
        
        override var frame: CGRect {
            get { return super.frame }
            set {
                var fixed = newValue
                if let superview = super.superview {
                    let bottom = superview.safeAreaInsets.bottom
                    fixed.origin.y = superview.bounds.height - fixed.height - bottom
                }
                super.frame = fixed
            }
        }
        
        override func draw(_ rect: CGRect) {
            addShape()
        }
        
        private func addShape() {
            let shape = CAShapeLayer()
            shape.path = dipPath()
            shape.fillColor = UIColor.white.cgColor
            
            shape.shadowOpacity = 0.12
            shape.shadowRadius = 16
            shape.shadowOffset = CGSize(width: 0, height: -2)
            
            if let old = shapeLayer {
                layer.replaceSublayer(old, with: shape)
            } else {
                layer.insertSublayer(shape, at: 0)
            }
            
            shapeLayer = shape
        }
        
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            if let circle = circleButtonRef,
               !circle.isHidden,
               circle.isUserInteractionEnabled {
                
                let converted = convert(point, to: circle)
                
                if circle.point(inside: converted, with: event) {
                    return circle
                }
            }
            return super.hitTest(point, with: event)
        }
        
        func dipPath() -> CGPath {
            let w = bounds.width
            let h: CGFloat = 60
            let mid = w / 2
            
            let dipW: CGFloat = 110
            let dipD: CGFloat = 30
            let r: CGFloat = 26
            
            let p = UIBezierPath()
            
            p.move(to: CGPoint(x: r, y: 0))
            p.addQuadCurve(to: CGPoint(x: 0, y: r),
                           controlPoint: CGPoint(x: 0, y: 0))
            
            p.addLine(to: CGPoint(x: 0, y: h))
            p.addLine(to: CGPoint(x: w, y: h))
            p.addLine(to: CGPoint(x: w, y: r))
            p.addQuadCurve(to: CGPoint(x: w - r, y: 0),
                           controlPoint: CGPoint(x: w, y: 0))
            let start = mid + dipW / 2
            let end = mid - dipW / 2
            p.addLine(to: CGPoint(x: start, y: 0))
            p.addQuadCurve(to: CGPoint(x: mid, y: dipD),
                           controlPoint: CGPoint(x: mid + dipW / 4, y: dipD))
            p.addQuadCurve(to: CGPoint(x: end, y: 0),
                           controlPoint: CGPoint(x: mid - dipW / 4, y: dipD))
            p.addLine(to: CGPoint(x: r, y: 0))
            p.close()
            return p.cgPath
        }
        
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            var s = super.sizeThatFits(size)
            s.height = 60
            return s
        }
    }
}
