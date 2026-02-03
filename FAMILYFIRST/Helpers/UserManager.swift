//
//  UserManager.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 03/02/26.
//

import Foundation

class UserManager {

    static let shared = UserManager()
    private init() {}

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let isLoggedIn = "isLoggedIn"
        static let mobile = "mobile"
    }

    func saveTokens(access: String, refresh: String) {
        defaults.set(access, forKey: Keys.accessToken)
        defaults.set(refresh, forKey: Keys.refreshToken)
        defaults.set(true, forKey: Keys.isLoggedIn)
    }

    func saveMobile(_ mobile: String) {
        defaults.set(mobile, forKey: Keys.mobile)
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

    var isLoggedIn: Bool {
        return defaults.bool(forKey: Keys.isLoggedIn) && !accessToken.isEmpty
    }

    func logout() {
        defaults.removeObject(forKey: Keys.accessToken)
        defaults.removeObject(forKey: Keys.refreshToken)
        defaults.removeObject(forKey: Keys.isLoggedIn)
        defaults.removeObject(forKey: Keys.mobile)
    }
}
