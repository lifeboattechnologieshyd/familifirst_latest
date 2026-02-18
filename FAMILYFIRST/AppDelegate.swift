//
//  AppDelegate.swift
//  FamilyFirst
//
//  Created by Lifeboat on 23/12/25.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseMessaging
import FirebaseCrashlytics
import FirebaseAnalytics
import UserNotifications
import IQKeyboardManagerSwift


@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true

        printEnvironmentInfo()
        configureFirebase()
        setupPushNotifications(application: application)
        setupNavigationBar()

        return true
    }
 
    
    private func printEnvironmentInfo() {
        let bundleID = Bundle.main.bundleIdentifier ?? "UNKNOWN"
        let serverURL = Bundle.main.object(forInfoDictionaryKey: "server_url") as? String ?? "NOT SET"
        
        var firebasePlistPath = "NOT FOUND"
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            firebasePlistPath = path
        }
        
    }
    private func configureFirebase() {
        if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let options = FirebaseOptions(contentsOfFile: filePath) {
            FirebaseApp.configure(options: options)
            print("✅ Firebase configured using: \(filePath)")
        } else {
            print("❌ GoogleService-Info.plist not found!")
        }

        Messaging.messaging().delegate = self
    }
    
    private func setupPushNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            print("🔔 Push permission granted: \(granted)")
            if let error = error {
                print("❌ Push permission error: \(error.localizedDescription)")
            }
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("📱 APNs token: \(token)")
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else {
            print("⚠️ No FCM token received.")
            return
        }
        
        let serverURL = Bundle.main.object(forInfoDictionaryKey: "server_url") as? String ?? "NOT SET"
        let isProd = serverURL.contains("prod")
        
        if isProd {
            print("🚀 PROD FCM token: \(token)")
        } else {
            print("🧩 DEV FCM token: \(token)")
        }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    private func setupNavigationBar() {
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.shadowColor = .lightGray
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}
