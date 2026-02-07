//
//  NetworkManager.swift
//  FamilyFirst
//
//  Created by Lifeboat on 14/01/26.
//

import Foundation

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case noaccess
    case decodingError(String)
    case serverError(String)
}

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}

    func request<T: Decodable>(
        urlString: String,
        method: HTTPMethod = .GET,
        is_testing : Bool = false,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Result<APIResponse<T>, NetworkError>) -> Void
    ) {
        
        guard var urlComponents = URLComponents(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        if method == .GET, let parameters = parameters {
            urlComponents.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }
        
        guard let url = urlComponents.url else {
            completion(.failure(.invalidURL))
            return
        }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        if let parameters = parameters, method == .POST || method == .PUT {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                completion(.failure(.decodingError(error.localizedDescription)))
                return
            }
        }
        let token = UserManager.shared.accessToken
        if !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }


        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            do {
                print(String.init(data: data, encoding: .utf8) ?? "-----")
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...399).contains(httpResponse.statusCode)  {
                        print("✅ Success: Status code is \(httpResponse.statusCode)")
                        if is_testing {
                            let decodedData = try JSONDecoder().decode(TestResponsere.self, from: data)
                            print(decodedData)
                        }
                        let decodedData = try JSONDecoder().decode(APIResponse<T>.self, from: data)
                        print(decodedData)
                        completion(.success(decodedData))
                    }else {
                        if httpResponse.statusCode == 401 {
                            completion(.failure(.noaccess))
                        }else{
                            print("❌ Error: Status code is \(httpResponse.statusCode)")
                            completion(.failure(.noData))
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
                completion(.failure(.decodingError(error.localizedDescription)))
            }
        }.resume()
    }
    
    func logDecodingError(_ error: Error?) {
        guard let decodingError = error as? DecodingError else {
            print("❌ Non-decoding error:", error)
            return
        }

        switch decodingError {

        case .typeMismatch(let type, let context):
            print("❌ Type mismatch for type:", type)
            print("📍 CodingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " → "))
            print("ℹ️ Debug:", context.debugDescription)

        case .valueNotFound(let type, let context):
            print("❌ Value not found for type:", type)
            print("📍 CodingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " → "))
            print("ℹ️ Debug:", context.debugDescription)

        case .keyNotFound(let key, let context):
            print("❌ Key not found:", key.stringValue)
            print("📍 CodingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " → "))
            print("ℹ️ Debug:", context.debugDescription)

        case .dataCorrupted(let context):
            print("❌ Data corrupted")
            print("📍 CodingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " → "))
            print("ℹ️ Debug:", context.debugDescription)

        @unknown default:
            print("❌ Unknown decoding error")
        }
    }

}

struct TestResponsere: Decodable {
    let success: Bool
    let errorCode: Int
    let total : Int?
    let description: String
    let data: LoginResponse
    
}

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let errorCode: Int
    let total : Int?
    let description: String
    let data: T?
    
    enum CodingKeys: String, CodingKey {
        case success, errorCode, description, total, data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        errorCode = try container.decode(Int.self, forKey: .errorCode)
        description = try container.decode(String.self, forKey: .description)
        total = try? container.decode(Int.self, forKey: .total)
        // 👇 This safely handles {} or missing fields
        data = try? container.decodeIfPresent(T.self, forKey: .data)
    }
}
struct LoginResponse: Decodable {
    let refreshToken: String?
    let accessToken: String?
    let username: String?
    let email: String?
    let mobile: Int?
    let referralCode: String?
    let profileImage: String?
    let isNewUser: Bool
    let setNewPassword: Bool

    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
        case accessToken = "access_token"
        case username
        case email
        case mobile
        case referralCode = "referral_code"
        case profileImage = "profile_image"
        case isNewUser = "is_new_user"
        case setNewPassword = "set_new_password"
    }
}
private enum BuildConfiguration {
    enum Error: Swift.Error {
        case missingkey, invalidValue
    }
    static func value<T>(for key: String) throws -> T where T : LosslessStringConvertible{
        
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else{
            throw Error.missingkey
        }
        switch object {
        case let string as String:
            guard let value = T(string) else {fallthrough}
            return value
        default:
            throw Error.invalidValue
        }
        
    }
}

enum PLISTVALUES {
    static var baseUrl : String {
        do{
            return try BuildConfiguration.value(for: "server_url")
        } catch {
            fatalError(error.localizedDescription)
        }
    }

}
struct API {

    static let BASE_URL: String = {
        let url = PLISTVALUES.baseUrl
        guard url.starts(with: "http") else {
            fatalError("❌ BASE_URL missing scheme: \(url)")
        }
        return url.hasSuffix("/") ? url : url + "/"
    }()
    
    static let GET_COMMENTS = BASE_URL + "edutain/comment"
    static let EDUTAIN_FEEL = BASE_URL + "events/get/feels"
    static let GET_ADDRESS = BASE_URL + "onlinestore/address"
    static let ONLINE_STORE_PRODUCTS = BASE_URL + "onlinestore/products"
    static let ONLINE_STORE_ADDRESS = BASE_URL + "onlinestore/address"
    static let CREATE_ADDRESS = BASE_URL + "onlinestore/address"
    static let CREATE_ORDER = BASE_URL + "onlinestore/order"
    static let VOCABEE_GET_DATES = BASE_URL + "vocabee/words/history"
    static let VOCABEE_GET_WORDS_BY_DATES = BASE_URL + "vocabee/daily/words"
    static let VOCABEE_PRACTICE_SUBMIT = BASE_URL + "vocabee/word"
    static let VOCABEE_GET_PRACTISE_WORDS = BASE_URL + "vocabee/get/word"
    static let GRADES = BASE_URL + "school/grade/unassigned"
    static let ADD_STUDENT = BASE_URL + "school/general/student"
    static let GRADES_LIST = BASE_URL + "school/grade/unassigned"
    static let ASSESSMENT_CREATE = BASE_URL + "assessments/create/assessments"
    static let ASSESSMENT_ATTEMPT = BASE_URL + "assessments/attempt/assessment"
    static let ASSESSMENT_HISTORY = BASE_URL + "assessments/past/assessments"
    static let ASSESSMENT_HISTORY_ANSWERS = BASE_URL + "assessments/myanswers"
    static let ASSESSMENT_RESULTS = BASE_URL + "assessments/result"
    static let CURRICULUM_TYPES = BASE_URL + "curriculum/curriculum"
    static let CURRICULUM_CATEGORIES = BASE_URL + "curriculum/categori?grade="
    static let SUBJECTS = BASE_URL + "curriculum/subject?grade="
    static let SEND_OTP = BASE_URL + "user/authentication/mobile/send-otp"
    static let VERIFY_OTP = BASE_URL + "user/authentication/mobile/verify-otp"
    static let RESEND_OTP = BASE_URL + "user/authentication/mobile/resend-otp"
    static let SET_PASSWORD = BASE_URL + "user/authentication/set-password"
    static let LOGIN_PASSWORD = BASE_URL + "user/authentication/mobile/login"
    static let GET_FEELS = BASE_URL + "event/get/feels"
    static let FAMILY_MASTER = BASE_URL + "family/familymaster"
    static let CREATE_EVENT = BASE_URL + "event/event"
    static let GET_EVENTS = "\(BASE_URL)event/get/event"
    
    static let VOCABEE_STATISTICS = "\(BASE_URL)vocabee/get/statistics"
    static let VOCABEE_GET_WORD = "\(BASE_URL)vocabee/get/word"
    static let VOCABEE_SUBMIT_WORD = "\(BASE_URL)vocabee/word"
    static let VOCABEE_WORDS_HISTORY = "\(BASE_URL)vocabee/words/history"
    static let VOCABEE_ATTEMPT_WORDS = "\(BASE_URL)vocabee/attempt/words"
    static let VOCABEE_DAILY_WORDS = "\(BASE_URL)vocabee/daily/words"
    static let VOCABEE_DAILY_HISTORY = "\(BASE_URL)vocabee/daily/history"
    static let VOCABEE_GET_GRADES = "\(BASE_URL)vocabee/grade"
    static let VOCABEE_WORD_LEVEL = "\(BASE_URL)vocabee/word/level"
    static let VOCABEE_GET_MYWORDS = "\(BASE_URL)vocabee/get/mywords"
    static let VOCABEE_GET_CONTEST = "\(BASE_URL)vocabee/get/contest"
    static let VOCABEE_GET_CONTEST_WORD = "\(BASE_URL)vocabee/get/contestword"
    static let VOCABEE_ATTEMPT_CONTEST_WORD = "\(BASE_URL)vocabee/attempt/contestword"
    
    static let EDUTAIN_FEEDS = "\(BASE_URL)edutain/feeds"
    static let EDUTAIN_FEED = "\(BASE_URL)edutain/feed"
    static let EDUTAIN_LIKE = "\(BASE_URL)edutain/like"
    static let EDUTAIN_COMMENT = "\(BASE_URL)edutain/comment"
    static let EDUTAIN_SEARCH = "\(BASE_URL)edutain/search"
    static let LIKE_FEED = "\(BASE_URL)edutain/feed/"
    static let POST_COMMENT = "\(BASE_URL)edutain/comment"
    static let WHATSAPP_SHARE = "\(BASE_URL)edutain/whatsapp/share"
    static let BROADCAST_CALENDAR = BASE_URL + "broadcast/calendar"
    static let EDUTAIN_SUBJECTS = "\(BASE_URL)edutain/subject"
    static let EDUTAIN_LESSONS = "\(BASE_URL)edutain/lesson"
    static let EDUTAIN_CREATE_ASSESSMENT = "\(BASE_URL)edutain/create/assessments"
    static let EDUTAIN_ASSESSMENT_ATTEMPT = "\(BASE_URL)edutain/attempt/assessment"
    static let EDUTAIN_ASSESSMENT_RESULTS = "\(BASE_URL)edutain/assessments/result"
    static let EDUTAIN_MY_RESULTS = "\(BASE_URL)edutain/myresults"
    static let EDUTAIN_GRADES = "\(BASE_URL)edutain/grades"
    static let EDUTAIN_GET_ASSESSMENTS = "\(BASE_URL)edutain/assessments"
    static let EDUTAIN_PAST_ASSESSMENTS = "\(BASE_URL)edutain/past/assessments"
    static let EDUTAIN_RESULT = "\(BASE_URL)edutain/result"
    static let EDUTAIN_GET_QUESTIONS = "\(BASE_URL)edutain/get/questions"
    static let EDUTAIN_MY_ANSWERS = "\(BASE_URL)edutain/myanswers"
    
    // Courses APIs
    static let OFFLINE_COURSES = "\(BASE_URL)courses/get/course"
    static let ONLINE_COURSES = "\(BASE_URL)courses/online/courses"
    static let WEBINARS = "\(BASE_URL)courses/get/webinar"
    

}


    

   
 






   

