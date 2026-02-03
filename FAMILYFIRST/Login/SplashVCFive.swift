//
//  SplashVCFive.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 28/01/26.
//
import UIKit

class SplashVCFive: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func getStartedTapped(_ sender: UIButton) {
        
        UserManager.shared.setOnboardingComplete()
        
        // Navigate to Home
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = storyboard.instantiateViewController(withIdentifier: "CustomTabBarController")
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = homeVC
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }
}
