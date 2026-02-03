import UIKit
import Kingfisher

// MARK: - Feed Cell Type
enum FeedCellType {
    case diy
    case stories
}

import Foundation

struct FeelItem: Codable {
    let id: String
    let youtubeVideo: String?
    let title: String?
    let description: String?
    let thumbnailImage: String?
    let likesCount: Int?
    let shareCount: Int?
    let viewsCount: Int?
    let score: Int?
    let category: String?
    let serialNumber: Int?
    var isLiked: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case youtubeVideo = "youtube_video"
        case title
        case description
        case thumbnailImage = "thumbnail_image"
        case likesCount = "likes_count"
        case shareCount = "share_count"
        case viewsCount = "views_count"
        case score
        case category
        case serialNumber = "serial_number"
        case isLiked = "is_liked"
    }
}

// ✅ Response wrapper
struct FeelsResponse: Codable {
    let success: Bool
    let errorCode: Int?
    let description: String
    let total: Int?
    let data: [FeelItem]?
    
    enum CodingKeys: String, CodingKey {
        case success
        case errorCode
        case description
        case total
        case data
    }
}

// MARK: - Feed Model
struct Feed: Codable {
    let id: String
    let heading: String
    let trending: Bool
    let feedType: String
    let categories: [String]?
    let image: String?
    let remarks: String?
    let schoolId: String?
    let video: String?
    let youtubeVideo: String?
    let description: String
    let description_2: String?
    var likesCount: Int
    var commentsCount: Int
    var whatsappShareCount: Int
    let language: String
    let duration: Int
    let postingDate: String
    let approvedBy: String?
    let approvedTime: String?
    let status: String
    let skill_tested: String?
    let lesson: String?
    let subject: String?
    let grade_id: String?
    let serial_number: Int
    var isLiked: Bool
    var shareCount: Int?
    let f_category: String?
    
    enum CodingKeys: String, CodingKey {
        case id, heading, trending, categories, image, remarks, video, description, language, duration, status, description_2, serial_number, grade_id, subject, lesson, skill_tested
        case feedType = "feed_type"
        case schoolId = "school_id"
        case youtubeVideo = "youtube_video"
        case likesCount = "likes_count"
        case commentsCount = "comments_count"
        case whatsappShareCount = "whatsapp_share_count"
        case postingDate = "posting_date"
        case approvedBy = "approved_by"
        case approvedTime = "approved_time"
        case isLiked = "is_liked"
        case shareCount = "share_count"
        case f_category
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        heading = try container.decode(String.self, forKey: .heading)
        description = try container.decode(String.self, forKey: .description)
        trending = try container.decodeIfPresent(Bool.self, forKey: .trending) ?? false
        feedType = try container.decodeIfPresent(String.self, forKey: .feedType) ?? "Image"
        status = try container.decodeIfPresent(String.self, forKey: .status) ?? "Published"
        language = try container.decodeIfPresent(String.self, forKey: .language) ?? "English"
        duration = try container.decodeIfPresent(Int.self, forKey: .duration) ?? 0
        postingDate = try container.decodeIfPresent(String.self, forKey: .postingDate) ?? ""
        serial_number = try container.decodeIfPresent(Int.self, forKey: .serial_number) ?? 0
        
        categories = try container.decodeIfPresent([String].self, forKey: .categories)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        remarks = try container.decodeIfPresent(String.self, forKey: .remarks)
        schoolId = try container.decodeIfPresent(String.self, forKey: .schoolId)
        video = try container.decodeIfPresent(String.self, forKey: .video)
        youtubeVideo = try container.decodeIfPresent(String.self, forKey: .youtubeVideo)
        description_2 = try container.decodeIfPresent(String.self, forKey: .description_2)
        approvedBy = try container.decodeIfPresent(String.self, forKey: .approvedBy)
        approvedTime = try container.decodeIfPresent(String.self, forKey: .approvedTime)
        skill_tested = try container.decodeIfPresent(String.self, forKey: .skill_tested)
        lesson = try container.decodeIfPresent(String.self, forKey: .lesson)
        subject = try container.decodeIfPresent(String.self, forKey: .subject)
        grade_id = try container.decodeIfPresent(String.self, forKey: .grade_id)
        f_category = try container.decodeIfPresent(String.self, forKey: .f_category)
        
        likesCount = try container.decodeIfPresent(Int.self, forKey: .likesCount) ?? 0
        commentsCount = try container.decodeIfPresent(Int.self, forKey: .commentsCount) ?? 0
        whatsappShareCount = try container.decodeIfPresent(Int.self, forKey: .whatsappShareCount) ?? 0
        shareCount = try container.decodeIfPresent(Int.self, forKey: .shareCount)
        
        isLiked = try container.decodeIfPresent(Bool.self, forKey: .isLiked) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(heading, forKey: .heading)
        try container.encode(description, forKey: .description)
        try container.encode(trending, forKey: .trending)
        try container.encode(feedType, forKey: .feedType)
        try container.encode(status, forKey: .status)
        try container.encode(language, forKey: .language)
        try container.encode(duration, forKey: .duration)
        try container.encode(postingDate, forKey: .postingDate)
        try container.encode(serial_number, forKey: .serial_number)
        try container.encode(likesCount, forKey: .likesCount)
        try container.encode(commentsCount, forKey: .commentsCount)
        try container.encode(whatsappShareCount, forKey: .whatsappShareCount)
        try container.encode(isLiked, forKey: .isLiked)
        
        try container.encodeIfPresent(categories, forKey: .categories)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(remarks, forKey: .remarks)
        try container.encodeIfPresent(schoolId, forKey: .schoolId)
        try container.encodeIfPresent(video, forKey: .video)
        try container.encodeIfPresent(youtubeVideo, forKey: .youtubeVideo)
        try container.encodeIfPresent(description_2, forKey: .description_2)
        try container.encodeIfPresent(approvedBy, forKey: .approvedBy)
        try container.encodeIfPresent(approvedTime, forKey: .approvedTime)
        try container.encodeIfPresent(skill_tested, forKey: .skill_tested)
        try container.encodeIfPresent(lesson, forKey: .lesson)
        try container.encodeIfPresent(subject, forKey: .subject)
        try container.encodeIfPresent(grade_id, forKey: .grade_id)
        try container.encodeIfPresent(f_category, forKey: .f_category)
        try container.encodeIfPresent(shareCount, forKey: .shareCount)
    }
}

// MARK: - ReadingShort Model
struct ReadingShort: Codable, Identifiable {
    let id: String
    let youtubeVideo: String
    let title: String
    let description: String
    let likesCount: Int
    let shareCount: Int
    let viewsCount: Int
    let score: Double
    let category: String
    let isLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case youtubeVideo = "youtube_video"
        case title
        case description
        case likesCount = "likes_count"
        case shareCount = "share_count"
        case viewsCount = "views_count"
        case score
        case category
        case isLiked = "is_liked"
    }
}

extension ReadingShort {
    var youtubeID: String? {
        guard let url = URL(string: youtubeVideo) else { return nil }
        let parts = url.pathComponents
        if parts.count >= 3, parts[1] == "shorts" { return parts[2] }
        if let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let v = comps.queryItems?.first(where: { $0.name == "v" })?.value {
            return v
        }
        return nil
    }
    
    var youtubeURL: URL? { URL(string: youtubeVideo) }
}

// MARK: - API Response Models
struct LikeResponse: Decodable {
    let likes_count: Int
    let is_liked: Bool
}

struct EmptyResponse: Codable {}

// MARK: - Comment Model
struct Comment: Codable {
    let commentId: String
    let userId: String
    let parentId: String?
    let comment: String
    let likesCount: Int
    let image: String?
    let userName: String
    let profilePic: String?
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case userId = "user_id"
        case parentId = "parent_id"
        case comment
        case likesCount = "likes_count"
        case image
        case userName = "user_name"
        case profilePic = "profile_pic"
        case createdAt = "created_at"
    }
}

extension Comment {
    var formattedTime: String {
        let date = Date(timeIntervalSince1970: TimeInterval(createdAt))
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct CommentsResponse: Codable {
    let comments: [Comment]
}

struct PostCommentResponse: Codable {
    let id: String
}

// MARK: - UIImageView Extension
extension UIImageView {
    
    func loadImage(url: String, placeHolderImage: String = "SchoolFirst") {
        guard let url = URL(string: url) else {
            self.image = UIImage(named: placeHolderImage)
            return
        }
        
        DispatchQueue.main.async {
            let size = self.bounds.size
            
            let finalSize = (size.width > 0 && size.height > 0)
            ? size
            : CGSize(width: UIScreen.main.bounds.width / 3,
                     height: UIScreen.main.bounds.width / 3)
            
            let processor = DownsamplingImageProcessor(size: finalSize)
            
            self.kf.indicatorType = .activity
            
            self.kf.setImage(
                with: url,
                placeholder: UIImage(named: placeHolderImage),
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0.2)),
                    .cacheOriginalImage,
                    .memoryCacheExpiration(.days(21)),
                    .diskCacheExpiration(.days(30))
                ]
            )
        }
    }
    
    func loadImage2(url: String, placeHolderImage: String = "SchoolFirst") {
        let processor = DownsamplingImageProcessor(size: self.bounds.size)
        self.kf.indicatorType = .activity
        self.kf.setImage(
            with: URL(string: url),
            placeholder: UIImage(named: placeHolderImage),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ]) { result in
                switch result {
                case .success(_):
                    break
                case .failure(let error):
                    print("error loading image for \(error)")
                }
            }
    }
}

// MARK: - Course Model
struct Course: Codable {
    let id: String
    let name: String
    let description: String
    let duration: Int
    let hosts: [String]
    let thumbnailImage: String
    let profileImage: String
    let videos: [String]
    let demoVideo: [String]?
    let images: [String]
    let courseFee: String
    let finalCourseFee: String
    let audience: String
    let language: String
    let enrollments: Int
    let numberOfChapters: Int
    let numberOfLessons: Int
    let completions: Int
    let trending: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, description, duration, hosts, videos, images, audience, language, enrollments, completions, trending
        case thumbnailImage = "thumbnail_image"
        case profileImage = "profile_image"
        case courseFee = "course_fee"
        case finalCourseFee = "final_course_fee"
        case numberOfChapters = "number_of_chapters"
        case numberOfLessons = "number_of_lessons"
        case demoVideo = "demo_video"
    }
}

// MARK: - OnlineCourse Model
struct OnlineCourse: Codable {
    let id: String
    let name: String
    let description: String
    let duration: Int
    let audience: String
    let thumbnailImage: String
    let profileImage: String?
    let demoVideo: [String]?
    let courseFee: String
    let finalCourseFee: String
    let trending: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, description, duration, audience, trending
        case thumbnailImage = "thumbnail_image"
        case profileImage = "profile_image"
        case demoVideo = "demo_video"
        case courseFee = "course_fee"
        case finalCourseFee = "final_course_fee"
    }
}
struct Product: Decodable {
    let id: String
    let itemName: String
    let itemDescription: String
    let thumbnailImage: String
    let listOfImages: [String]
    let mrp: String
    let finalPrice: String
    let discountTag: String?
    let highlights: [String]?
    let isTrending: Bool
    let variants: Variants?
    let specification: [String]?  // 👈 This is important


    enum CodingKeys: String, CodingKey {
        case id
        case itemName = "item_name"
        case itemDescription = "item_description"
        case thumbnailImage = "thumbnail_image"
        case listOfImages = "list_of_images"
        case mrp
        case finalPrice = "final_price"
        case discountTag = "discount_tag"
        case highlights
        case isTrending = "is_trending"
        case variants
        case specification

    }
}

// MARK: - OfflineCourse Model
struct OfflineCourse: Codable {
    let id: String
    let name: String
    let description: String
    let audience: String
    let venue: String
    let venueFullAddress: String
    let venueLocationLink: String
    let totalSlots: Int
    let totalEnrolled: Int
    let entryFee: String
    let thumbnailImage: String
    let date: Int64
    let trending: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, audience, venue, date, trending
        case venueFullAddress = "venue_full_address"
        case venueLocationLink = "venue_location_link"
        case totalSlots = "total_slots"
        case totalEnrolled = "total_enrolled"
        case entryFee = "entry_fee"
        case thumbnailImage = "thumbnail_image"
    }
}

// MARK: - Webinar Model
struct Webinar: Codable {
    let id: String
    let name: String
    let description: String
    let audience: String
    let webinarLink: String
    let totalSlots: Int
    let totalEnrolled: Int
    let entryFee: String
    let duration: Int
    let thumbnailImage: String
    let date: Int64
    let trending: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, audience, duration, date, trending
        case webinarLink = "webinar_link"
        case totalSlots = "total_slots"
        case totalEnrolled = "total_enrolled"
        case entryFee = "entry_fee"
        case thumbnailImage = "thumbnail_image"
    }
}
// MARK: - Create Order Response
struct CreateOrderResponseModel: Codable {
    let id: String?
    let orderId: String?
    let orderStatus: String?
    let paymentSessionId: String?
    let paymentLink: String?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case orderId = "order_id"
        case orderStatus = "order_status"
        case paymentSessionId = "payment_session_id"
        case paymentLink = "payment_link"
        case message
    }

    
    var getOrderId: String? {
        return orderId ?? id
    }
}
struct CashfreeOrderResponse: Codable {
    let cfOrderId: String?
    let orderId: String?
    let paymentSessionId: String?
    let orderStatus: String?
    let orderAmount: Double?
    let orderCurrency: String?
    let orderExpiryTime: String?
    
    // For error response
    let message: String?
    let code: String?
    let type: String?
    
    enum CodingKeys: String, CodingKey {
        case cfOrderId = "cf_order_id"
        case orderId = "order_id"
        case paymentSessionId = "payment_session_id"
        case orderStatus = "order_status"
        case orderAmount = "order_amount"
        case orderCurrency = "order_currency"
        case orderExpiryTime = "order_expiry_time"
        case message, code, type
    }
}

struct CreateAddressResponseModel: Codable {
    let id: String?
    let addressId: String?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case addressId = "address_id"
        case message
    }
}

struct FullAddress: Codable {
    let street: String?
    let country: String?
    let village: String?
    let district: String?
    let houseNo: String?
    let landmark: String?
    
    enum CodingKeys: String, CodingKey {
        case street, country, village, district, landmark
        case houseNo = "house_no"
    }
}

struct AddressModel: Codable {
    let id: String
    let userId: String?
    let contactNumber: Int?
    let fullName: String?
    let fullAddress: FullAddress?
    let mobile: Int?
    let placeName: String?
    let stateName: String?
    let pinCode: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case contactNumber = "contact_number"
        case fullName = "full_name"
        case fullAddress = "full_address"
        case mobile
        case placeName = "place_name"
        case stateName = "state_name"
        case pinCode = "pin_code"
    }
}


// MARK: VocabBee Models
struct VocabBeeStatistics: Codable {
    let totalQuestions: Int?
    let correctAnswers: Int?
    let wrongAnswers: Int?
    let totalPoints: Int?
    let lastAnswerPoints: Int?
    let level: Int?
    let totalWords: Int?
    
    enum CodingKeys: String, CodingKey {
        case totalQuestions = "total_questions"
        case correctAnswers = "correct_answers"
        case wrongAnswers = "wrong_answers"
        case totalPoints = "total_points"
        case lastAnswerPoints = "last_answer_points"
        case level
        case totalWords = "total_words"
    }
}

struct VocabBeeWordResponse: Codable {
    let id: String
    let wordID: String
    let userAnswer: String?
    let correctAnswer: String
    let isCorrect: Bool
    let points: Int

    enum CodingKeys: String, CodingKey {
        case id
        case wordID = "word_id"
        case userAnswer = "user_answer"
        case correctAnswer = "correct_answer"
        case isCorrect = "is_correct"
        case points
    }
}

// MARK:  Store Item Model
struct StoreItem: Codable {
    let id: String
    let itemName: String
    let itemDescription: String
    let thumbnailImage: String
    let listOfImages: [String]
    let mrp: String
    let finalPrice: String
    let discountTag: String?
    let highlights: [String]?
    let isTrending: Bool
    let variants: Variants?
    let specification: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case itemName = "item_name"
        case itemDescription = "item_description"
        case thumbnailImage = "thumbnail_image"
        case listOfImages = "list_of_images"
        case mrp
        case finalPrice = "final_price"
        case discountTag = "discount_tag"
        case highlights
        case isTrending = "is_trending"
        case variants
        case specification
    }
}

// MARK: Variants Model
struct Variants: Codable {
    let colors: [String]?
    let sizes: [String]?
}
struct WordInfo: Codable {
    let id: String
    let word: String
    let definition: String
    let points: Int
    let usage: String
    let origin: String
    let partsOfSpeech: String?
    let others: String?
    let othersVoice: String?
    let pronunciation: String
    let partsOfSpeechVoice: String
    let definitionVoice: String
    let originVoice: String
    let usageVoice: String
    let date: String?

    enum CodingKeys: String, CodingKey {
        case id
        case word
        case definition
        case points
        case usage
        case origin
        case partsOfSpeech = "parts_of_speech"
        case others
        case othersVoice = "others_voice"
        case pronunciation
        case partsOfSpeechVoice = "parts_of_speech_voice"
        case definitionVoice = "definition_voice"
        case originVoice = "origin_voice"
        case usageVoice = "usage_voice"
        case date
    }
}
struct WordAnswer: Codable {
    let wordId: String
    let userAnswer: String?
    let correctAnswer: String
    let isCorrect: Bool
    let points: Int
    let earned_points: Int
    let total_points: Int
    
    enum CodingKeys: String, CodingKey {
        case wordId = "word_id"
        case userAnswer = "user_answer"
        case correctAnswer = "correct_answer"
        case isCorrect = "is_correct"
        case points, earned_points, total_points
    }
}
struct VocabeeDate: Codable {
    let date: String
    let totalWords: Int
    let minutes: Int
    let attemptedWords: Int
    let pointsEarned: Int
    let totalPoints: Int
    
    enum CodingKeys: String, CodingKey {
            case date
            case totalWords = "total_words"
            case minutes
            case attemptedWords = "attempted_words"
            case pointsEarned = "points_earned"
            case totalPoints = "total_points"
        }
}
struct GradeModel: Codable {
    let id: String
    let schoolID: String?
    let name: String
    let section: String
    let numericGrade: Int

    enum CodingKeys: String, CodingKey {
        case id
        case schoolID = "school_id"
        case name
        case section
        case numericGrade = "numeric_grade"
    }
}
struct Grade: Codable {
    let id: String
    let schoolId: String?
    let name: String
    let section: String?
    let numericGrade: Int?
    let age: String?  
    
    enum CodingKeys: String, CodingKey {
        case id
        case schoolId = "school_id"
        case name
        case section
        case numericGrade = "numeric_grade"
        case age
    }
}
struct StudentUpdateResponse: Codable {
    let id: String?
    let studentID: String?
    let studentName: String?
    let name: String?
    let image: String?
    let gradeName: String?
    let gradeId: String?
    let dob: String?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case id
        case studentID = "student_id"
        case studentName = "student_name"
        case name
        case image
        case gradeName = "grade_name"
        case gradeId = "grade_id"
        case dob
        case status
    }
    
    // Helper: Get final ID and name
    var finalID: String {
        return id ?? studentID ?? ""
    }
    
    var finalName: String {
        return studentName ?? name ?? "Student"
    }
}
//struct Student: Codable {
//    let studentID: String
//    let name: String
//    let image: String?
//    let fatherName: String?
//    let motherName: String?
//    let dob: String?
//    let address: String?
//    let mobile: String?
//    let email_json: [[String:String]]?
////    let mobile_json: [ContactJson]?
//    let grade: String
//    let gradeID: String
//    let section: String?
//    let numeric_grade: Int
//
//
//    enum CodingKeys: String, CodingKey {
//        case studentID = "student_id"
//        case name, mobile_json, email_json
//        case image
//        case fatherName = "father_name"
//        case motherName = "mother_name"
//        case dob
//        case address
//        case mobile
//        case grade
//        case gradeID = "grade_id"
//        case school = "schools"
//        case section, numeric_grade
//    }
//    
//    // ✅ Add computed property for id
//    var id: String {
//        return studentID
//    }
//    
//    // ✅ Add display name for convenience
//    var displayName: String {
//        return name.isEmpty ? "Student" : name
//    }
//    
//    // ✅ Add grade section for display
//    var gradeSection: String {
//        if !grade.isEmpty && (section != nil) {
//            return "\(grade) - \(section)"
//        }
//        return grade
//    }
//    
//    // ✅ Keep your initializer
//    init(studentID: String, name: String, image: String?, fatherName: String, motherName: String, dob: String?, address: String?, mobile: String?, grade: String, gradeID: String, section: String, numeric_grade: Int, school: School?) {
//        self.studentID = studentID
//        self.name = name
//        self.image = image
//        self.fatherName = fatherName
//        self.motherName = motherName
//        self.dob = dob
//        self.address = address
//        self.mobile = mobile
//        self.grade = grade
//        self.gradeID = gradeID
//        self.section = section
//        self.numeric_grade = numeric_grade
//        self.school = nil
//        self.mobile_json = nil
//        self.email_json = nil
//    }
//}
struct AssessmentQuestionHistoryDetails: Codable {
    let id: String
    let assessmentId: String
    let questionId: String
    let questionName: String
    let questionType: String
    let options: [String]
    let correctAnswer: String
    let description: String?
    let answerDescription: String?
    let questionMarks: Int
    let userId: String
    let studentId: String
    let userAnswer: String?
    let isCorrect: Bool
    let marks: Int

    enum CodingKeys: String, CodingKey {
        case id
        case assessmentId = "assessment_id"
        case questionId = "question_id"
        case questionName = "question_name"
        case questionType = "question_type"
        case options
        case correctAnswer = "correct_answer"
        case description
        case answerDescription = "ans_description"
        case questionMarks = "question_marks"
        case userId = "user_id"
        case studentId = "student_id"
        case userAnswer = "user_answer"
        case isCorrect = "is_correct"
        case marks
    }
}
struct AssessmentSummary: Codable {
    let assessmentId: String
    let assessmentName: String
    let description: String
//    let answer: String
    let numberOfQuestions: Int
    let totalMarks: Int
    let studentMarks: Int
    let status: String

    enum CodingKeys: String, CodingKey {
        case assessmentId = "assessment_id"
        case assessmentName = "assessment_name"
        case description
//        case answer
        case numberOfQuestions = "number_of_questions"
        case totalMarks = "total_marks"
        case studentMarks = "student_marks"
        case status
    }
}
struct Lesson: Codable {
    let id: String
    let lessonName: String
    let categoryId: String
    let subjectId: String
    let gradeId: String
    let numberOfConcepts: Int
    let description: String
    let status: String
    let subscription: String
    var selected : Bool = false

    enum CodingKeys: String, CodingKey {
        case id
        case lessonName = "lesson_name"
        case categoryId = "category_id"
        case subjectId = "subject_id"
        case gradeId = "grade_id"
        case numberOfConcepts = "number_of_concepts"
        case description
        case status
        case subscription, selected
    }
    init(from decoder: Decoder) throws {
          let container = try decoder.container(keyedBy: CodingKeys.self)
          id = try container.decode(String.self, forKey: .id)
          lessonName = try container.decode(String.self, forKey: .lessonName)
          categoryId = try container.decode(String.self, forKey: .categoryId)
          subjectId = try container.decode(String.self, forKey: .subjectId)
          gradeId = try container.decode(String.self, forKey: .gradeId)
          numberOfConcepts = try container.decode(Int.self, forKey: .numberOfConcepts)
          description = try container.decode(String.self, forKey: .description)
          status = try container.decode(String.self, forKey: .status)
          subscription = try container.decode(String.self, forKey: .subscription)
          selected = try container.decodeIfPresent(Bool.self, forKey: .selected) ?? false
      }
}
struct AssessmentResult: Codable {
    let assessmentID: String
    let studentID: String
    let status: String
    let totalMarks: Int
    let studentMarks: Int
    let attemptedQuestions: Int
    let correctQuestions: Int
    let wrongQuestions: Int
    let skippedQuestions: Int

    enum CodingKeys: String, CodingKey {
        case assessmentID = "assessment_id"
        case studentID = "student_id"
        case status
        case totalMarks = "total_marks"
        case studentMarks = "student_marks"
        case attemptedQuestions = "attempted_questions"
        case correctQuestions = "correct_questions"
        case wrongQuestions = "wrong_questions"
        case skippedQuestions = "skipped_questions"
    }
}
class AssessmentAnswerResponse: Codable {
    let id: String
    let questionId: String
    let assessmentId: String
    let userId: String
    let studentId: String
    let userAnswer: String
    let isCorrect: Bool
    let marks: Int
    let totalMarks: Int
    let attemptedQuestions: Int
    let totalQuestions: Int
    let assessmentStatus: String

    enum CodingKeys: String, CodingKey {
        case id
        case questionId = "question_id"
        case assessmentId = "assessment_id"
        case userId = "user_id"
        case studentId = "student_id"
        case userAnswer = "user_answer"
        case isCorrect = "is_correct"
        case marks
        case totalMarks = "total_marks"
        case attemptedQuestions = "attempted_questions"
        case totalQuestions = "total_questions"
        case assessmentStatus = "assessment_status"
    }
}
struct Curriculum: Codable, Identifiable {
    let id: String
    let curriculumName: String
    let description: String?
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case curriculumName = "curriculum_name"
        case description
        case status
    }
}
struct Assessment: Codable {
    let id: String
    let gradeID: String
    let gradeName: String
    let subjectID: String
    let subjectName: String
    let name: String
    let description: String
    let numberOfQuestions: Int
    let attemptedQuestions: Int
    let isEvaluationRequired: Bool
    let totalMarks: Int
    let status: String
    let questions: [AssessmentQuestion]

    enum CodingKeys: String, CodingKey {
        case id
        case gradeID = "grade_id"
        case gradeName = "grade_name"
        case subjectID = "subject_id"
        case subjectName = "subject_name"
        case name
        case description
        case numberOfQuestions = "number_of_questions"
        case attemptedQuestions = "attempted_questions"
        case isEvaluationRequired = "is_evaluation_required"
        case totalMarks = "total_marks"
        case status
        case questions
    }
}
struct AssessmentQuestion: Codable {
    let id: String
    let questionType: String
    let question: String
    let options: [String]
    let answer: String
    let description: String
    let marks: Int
    let subjectID: String
    let gradeID: String
    let hint: String
    let skillTested: String
    let levelOfDifficulty: Int

    enum CodingKeys: String, CodingKey {
        case id
        case questionType = "question_type"
        case question
        case options
        case answer
        case description
        case marks
        case subjectID = "subject_id"
        case gradeID = "grade_id"
        case hint
        case skillTested = "skill_tested"
        case levelOfDifficulty = "level_of_difficulty"
    }
}
struct Student: Codable {
    let studentID: String
    let name: String
    let image: String?
    let fatherName: String?
    let motherName: String?
    let dob: String?
    let address: String?
    let mobile: String?
    let email_json: [[String: String]]?
    let grade: String
    let gradeID: String
    let section: String?
    let numeric_grade: Int

    enum CodingKeys: String, CodingKey {
        case studentID = "student_id"
        case name
        case image
        case fatherName = "father_name"
        case motherName = "mother_name"
        case dob
        case address
        case mobile
        case email_json
        case grade
        case gradeID = "grade_id"
        case section
        case numeric_grade
    }

    // Computed properties are SAFE ✅
    var id: String { studentID }

    var displayName: String {
        name.isEmpty ? "Student" : name
    }

    var gradeSection: String {
        if let section = section, !section.isEmpty {
            return "\(grade) - \(section)"
        }
        return grade
    }
}
struct GradeSubject: Codable {
    let id: String
    let subjectName: String
    let subjectImage: String
    let categoryId: String
    let gradeIds: [String]
    let gradeName: String
    let numberOfLessons: Int
    let status: String

    enum CodingKeys: String, CodingKey {
        case id
        case subjectName = "subject_name"
        case subjectImage = "subject_image"
        case categoryId = "category_id"
        case gradeIds = "grade_ids"
        case gradeName = "grade_name"
        case numberOfLessons = "number_of_lessons"
        case status
    }
}
// SendOTPResponse - for send-otp API
struct SendOTPResponse: Decodable {
    let passwordRequired: Bool
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case passwordRequired = "password_required"
        case message
    }
}

// VerifyOTPResponse - for verify-otp API
struct VerifyOTPResponse: Decodable {
    let refreshToken: String?
    let accessToken: String?
    let username: String?
    let email: String?
    let mobile: Int?
    let referralCode: String?
    let profileImage: String?
    let isNewUser: Bool?
    let setNewPassword: Bool?

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

