//
//  UserManager.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 03/02/26.
//

import UIKit

class UserManager {

    static let shared = UserManager()
    private init() {}

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let isLoggedIn = "isLoggedIn"
        static let mobile = "mobile"
        static let email = "email"
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let userId = "userId"
        static let profileImage = "userProfileImage"
    }
    var calender: LifeSkillPrompt?

    var hasSeenOnboarding: Bool {
        return defaults.bool(forKey: Keys.hasSeenOnboarding)
    }
    
    func setOnboardingComplete() {
        defaults.set(true, forKey: Keys.hasSeenOnboarding)
    }

    func saveTokens(access: String, refresh: String) {
        defaults.set(access, forKey: Keys.accessToken)
        defaults.set(refresh, forKey: Keys.refreshToken)
        defaults.set(true, forKey: Keys.isLoggedIn)
    }

    func saveMobile(_ mobile: String) {
        defaults.set(mobile, forKey: Keys.mobile)
    }
    
    func saveEmail(_ email: String) {
        defaults.set(email, forKey: Keys.email)
    }
    
    func saveUserId(_ userId: String) {
        defaults.set(userId, forKey: Keys.userId)
        print("Saved userId: \(userId)")
    }

    var accessToken: String {
        return defaults.string(forKey: Keys.accessToken) ?? ""
    }
    
    var refreshToken: String {
        return defaults.string(forKey: Keys.refreshToken) ?? ""
    }
    
    var mobile: String {
        return defaults.string(forKey: Keys.mobile) ?? ""
    }
    
    var email: String {
        return defaults.string(forKey: Keys.email) ?? ""
    }

    var isLoggedIn: Bool {
        return defaults.bool(forKey: Keys.isLoggedIn) && !accessToken.isEmpty
    }
    
    var userId: String? {
        let id = defaults.string(forKey: Keys.userId)
        print("UserManager userId: \(id ?? "NIL")")
        return id
    }
    
    
    func saveProfileImage(_ image: UIImage) {
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            defaults.set(imageData, forKey: Keys.profileImage)
            defaults.synchronize()
            print("✅ Profile image saved to UserDefaults")
        }
    }
    
    var profileImage: UIImage? {
        if let imageData = defaults.data(forKey: Keys.profileImage),
           let image = UIImage(data: imageData) {
            return image
        }
        return nil
    }
    
    var hasProfileImage: Bool {
        return defaults.data(forKey: Keys.profileImage) != nil
    }
    
    func removeProfileImage() {
        defaults.removeObject(forKey: Keys.profileImage)
        defaults.synchronize()
        print("🗑️ Profile image removed from UserDefaults")
    }
    
    
    func logout() {
        defaults.removeObject(forKey: Keys.accessToken)
        defaults.removeObject(forKey: Keys.refreshToken)
        defaults.removeObject(forKey: Keys.isLoggedIn)
        defaults.removeObject(forKey: Keys.mobile)
        defaults.removeObject(forKey: Keys.email)
        defaults.removeObject(forKey: Keys.userId)
        defaults.removeObject(forKey: Keys.profileImage)
        defaults.synchronize()
        print("🚪 User logged out - all data cleared")
    }
}
