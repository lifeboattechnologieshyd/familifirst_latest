//
//  SplashVCFive.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 28/01/26.
//
import UIKit

class SplashVCFive: UIViewController {

    @IBOutlet weak var nextBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func nextBtnTapped(_ sender: UIButton) {
        // Mark onboarding complete
        UserManager.shared.setOnboardingComplete()
        
        // Go to Login
        goToLogin()
    }
    
    private func goToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        let nav = UINavigationController(rootViewController: loginVC)
        nav.isNavigationBarHidden = true
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = nav
            window.makeKeyAndVisible()
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
}
