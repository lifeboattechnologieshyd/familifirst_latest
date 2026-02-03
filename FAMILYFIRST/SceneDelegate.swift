//
//  SceneDelegate.swift
//  FamilyFirst
//
//  Created by Lifeboat on 23/12/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let initialVC: UIViewController
        
        if !UserManager.shared.hasSeenOnboarding {
            // ✅ First time → Splash screens
            initialVC = storyboard.instantiateViewController(withIdentifier: "SplashVCOne")
            
        } else if UserManager.shared.isLoggedIn {
            // ✅ Already logged in → Home
            initialVC = storyboard.instantiateViewController(withIdentifier: "CustomTabBarController")
            
        } else {
            // ✅ Seen onboarding but not logged in → LoginVC
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")
            let nav = UINavigationController(rootViewController: loginVC)
            nav.isNavigationBarHidden = true
            initialVC = nav
        }
        
        window?.rootViewController = initialVC
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
