//
//  UIExtensions.swift
//  FamilyFirst
//
//  Created by Lifeboat on 09/01/26.
//
import UIKit
import ObjectiveC

private var loaderKey: UInt8 = 0


extension UIView {
    
    func addBottomShadow(
        shadowColor: UIColor = .black,
        shadowOpacity: Float = 0.2,
        shadowRadius: CGFloat = 4,
        shadowHeight: CGFloat = 3
    ) {
        layer.masksToBounds = false
        superview?.clipsToBounds = false
        
        // This offset pushes shadow only downward
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
        
        // Create a shadow path only at the bottom
        let shadowRect = CGRect(
            x: 0,
            y: bounds.height - shadowHeight,
            width: bounds.width,
            height: shadowHeight
        )
        layer.shadowPath = UIBezierPath(rect: shadowRect).cgPath
    }
    
    
    func applyCardShadow(
        cornerRadius: CGFloat = 8,
        shadowColor: UIColor = .black,
        shadowOpacity: Float = 0.3,
        shadowRadius: CGFloat = 3,
        shadowOffset: CGSize = CGSize(width: 0, height: 2)
    ){
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOffset = shadowOffset
        self.layer.masksToBounds = false
        self.backgroundColor = .white
        
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let cgColor = layer.borderColor else { return nil }
            return UIColor(cgColor: cgColor)
        }
        set { layer.borderColor = newValue?.cgColor }
    }
}
    extension UIView {
        func addCardShadow() {
            self.layer.cornerRadius = 8
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOpacity = 0.12
            self.layer.shadowOffset = CGSize(width: 0, height: 4)
            self.layer.shadowRadius = 6
            self.layer.masksToBounds = false
        }
    }

extension UIView {
    
    func applyDropShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.12
        self.layer.shadowRadius = 6
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.masksToBounds = false
    }
    
    func addTopShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: -3)
        layer.shadowRadius = 3
        layer.masksToBounds = false
    }
    
    func addBottomShadow(shadowOpacity: Float = 0.2, shadowRadius: CGFloat = 3, shadowHeight: CGFloat = 4) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
        layer.shadowRadius = shadowRadius
        layer.masksToBounds = false
    }
    func addDottedBorder(color: UIColor = .lightGray, cornerRadius: CGFloat = 10) {

            // make sure layout is up to date
            layoutIfNeeded()

            // remove any existing border
            layer.sublayers?
                .filter { $0.name == "dotted-border" }
                .forEach { $0.removeFromSuperlayer() }

            let shapeLayer = CAShapeLayer()
            shapeLayer.name = "dotted-border"
            shapeLayer.strokeColor = color.cgColor
            shapeLayer.lineDashPattern = [6, 3]
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.lineWidth = 1.5

            // IMPORTANT: draw inside the bounds so it doesn't cut
            let rect = bounds.insetBy(dx: shapeLayer.lineWidth / 2,
                                      dy: shapeLayer.lineWidth / 2)
            shapeLayer.frame = bounds
            shapeLayer.path = UIBezierPath(
                roundedRect: rect,
                cornerRadius: cornerRadius
            ).cgPath

            layer.addSublayer(shapeLayer)
        }
}
// MARK: - YouTube String Extensions
extension String {
    
    // MARK: Extract YouTube Video ID (All URL formats)
    func extractYoutubeId() -> String? {
        
        // Pattern 1: https://youtu.be/VIDEO_ID
        if self.contains("youtu.be/") {
            let components = self.components(separatedBy: "youtu.be/")
            if components.count > 1 {
                let videoID = components[1].components(separatedBy: "?").first ?? components[1]
                return videoID
            }
        }
        
        // Pattern 2: https://www.youtube.com/watch?v=VIDEO_ID
        if self.contains("youtube.com/watch") {
            if let url = URL(string: self),
               let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
                for item in queryItems {
                    if item.name == "v", let value = item.value {
                        return value
                    }
                }
            }
        }
        
        // Pattern 3: https://youtube.com/shorts/VIDEO_ID
        if self.contains("youtube.com/shorts") {
            if let url = URL(string: self) {
                return url.lastPathComponent
            }
        }
        
        // Pattern 4: https://youtube.com/embed/VIDEO_ID
        if self.contains("youtube.com/embed/") {
            let components = self.components(separatedBy: "embed/")
            if components.count > 1 {
                let videoID = components[1].components(separatedBy: "?").first ?? components[1]
                return videoID
            }
        }
        
        // Pattern 5: https://youtube.com/v/VIDEO_ID
        if self.contains("youtube.com/v/") {
            let components = self.components(separatedBy: "/v/")
            if components.count > 1 {
                let videoID = components[1].components(separatedBy: "?").first ?? components[1]
                return videoID
            }
        }
        
        return nil
    }
    
    // MARK: Get YouTube Thumbnail URL
    func youtubeThumbnailURL(quality: String = "hqdefault") -> String {
        "https://img.youtube.com/vi/\(self)/\(quality).jpg"
    }
}
extension UIView {
    
    func homeScreenCardLook (
        cornerRadius: CGFloat = 8,
        shadowColor: UIColor = UIColor.black.withAlphaComponent(0.3),
        shadowOpacity: Float = 0.3,
        shadowRadius: CGFloat = 12,
        shadowOffset: CGSize = CGSize(width: 0, height: 8)
    ) {
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOffset = shadowOffset
        self.layer.masksToBounds = false
        layer.borderColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
        layer.borderWidth = 0.5
    }
    
}
    enum LexendFont: String {
        case regular = "Lexend-Regular"
        case bold = "Lexend-Bold"
        case light = "Lexend-Light"
        case medium = "Lexend-Medium"
        case semiBold = "Lexend-SemiBold"
        case extraLight = "Lexend-ExtraLight"
        case thin = "Lexend-Thin"
        case black = "Lexend-Black"
    }

extension UIFont {
static func lexend(_ style: LexendFont, size: CGFloat) -> UIFont {
    return UIFont(name: style.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
}
}
extension UIViewController {
    func showAlert(msg: String){
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .default) { action in
            }
            alert.addAction(action)
            self.present(alert, animated: true)
        }
        
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var cleanedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cleanedHex.hasPrefix("#") {
            cleanedHex.remove(at: cleanedHex.startIndex)
        }
        
        guard cleanedHex.count == 6 else { return nil }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cleanedHex).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
extension UILabel {
    
    /// Set HTML string to label as attributed text.
    ///
    /// - Parameters:
    ///   - html: HTML string (may include <b>, <i>, <br>, <p>, <a>, <img> etc.)
    ///   - font: optional font to apply as a base (preserves bold/italic traits)
    ///   - color: optional color to apply as a base
    ///   - lineBreakMode: optional lineBreakMode (defaults to label's current)
    func setHTML(_ html: String,
                 font baseFont: UIFont? = nil,
                 color baseColor: UIColor? = nil,
                 lineBreakMode: NSLineBreakMode? = nil) {
        // Ensure UI work on main thread
        let apply: (NSAttributedString?) -> Void = { [weak self] attributed in
            guard let self = self else { return }
            if let lineBreak = lineBreakMode {
                self.lineBreakMode = lineBreak
            }
            if let attributed = attributed {
                self.numberOfLines = 0
                self.attributedText = attributed
            } else {
                // fallback to plain text if parsing fails
                self.text = html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            }
        }
        
        if Thread.isMainThread == false {
            DispatchQueue.main.async { [weak self] in
                guard self != nil else { return }
                _ = self // capture self to silence unused warning in closure
            }
        }
        
        // Convert HTML -> Data
        guard let data = html.data(using: .utf8) else {
            apply(nil)
            return
        }
        
        // Read options
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Parse HTML into NSAttributedString
            let parsed: NSAttributedString?
            do {
                let raw = try NSMutableAttributedString(
                    data: data,
                    options: options,
                    documentAttributes: nil
                )
                // If a base font or color is provided, normalize fonts & colors while preserving traits
                if let baseFont = baseFont {
                    raw.beginEditing()
                    raw.enumerateAttribute(.font, in: NSRange(location: 0, length: raw.length), options: []) { value, range, _ in
                        if let currentFont = value as? UIFont {
                            // Preserve traits (bold/italic)
                            let traits = currentFont.fontDescriptor.symbolicTraits
                            if let descriptor = baseFont.fontDescriptor.withSymbolicTraits(traits) {
                                let newFont = UIFont(descriptor: descriptor, size: baseFont.pointSize)
                                raw.addAttribute(.font, value: newFont, range: range)
                            } else {
                                raw.addAttribute(.font, value: baseFont, range: range)
                            }
                        } else {
                            raw.addAttribute(.font, value: baseFont, range: range)
                        }
                    }
                    raw.endEditing()
                }
                
                if let baseColor = baseColor {
                    raw.addAttribute(.foregroundColor, value: baseColor, range: NSRange(location: 0, length: raw.length))
                }
                
                parsed = raw
            } catch {
                parsed = nil
            }
            
            // Apply on main thread
            DispatchQueue.main.async {
                apply(parsed)
            }
        }
    }
    
    
    func addPadding(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        let paddingView = UIView()
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        self.superview?.insertSubview(paddingView, belowSubview: self)
        
        NSLayoutConstraint.activate([
            paddingView.topAnchor.constraint(equalTo: self.topAnchor, constant: -top),
            paddingView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -left),
            paddingView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: right),
            paddingView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottom)
        ])
        paddingView.backgroundColor = self.backgroundColor
        self.backgroundColor = .clear
    }
    func setTyping(text: String, charInterval: TimeInterval = 0.06) {
        self.text = ""
        var index = 0
        let characters = Array(text)
        
        Timer.scheduledTimer(withTimeInterval: charInterval, repeats: true) { timer in
            if index < characters.count {
                self.text?.append(characters[index])
                index += 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    func animateTyping(text: String, interval: TimeInterval = 0.06, completion: (() -> Void)? = nil) {
        self.text = ""
        var index = 0
        let characters = Array(text)

        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if index < characters.count {
                self.text?.append(characters[index])
                index += 1
            } else {
                timer.invalidate()
                completion?()
            }
        }
    }
    
    
    
}

extension UITextView {
    /// Converts HTML string into formatted attributed text and displays in the UITextView
    ///
    /// - Parameters:
    ///   - html: The HTML string you want to render
    ///   - font: Optional base font (applied while preserving HTML styles)
    ///   - color: Optional base color (default = label color)
    func setHTML(_ html: String,
                 font: UIFont? = .lexend(.regular, size: 16),
                 color: UIColor? = .black) {
        
        guard let data = html.data(using: .utf8) else {
            self.text = html
            return
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        DispatchQueue.global(qos: .userInitiated).async {
            let attributed: NSMutableAttributedString?
            
            do {
                let raw = try NSMutableAttributedString(
                    data: data,
                    options: options,
                    documentAttributes: nil
                )
                attributed = raw
            } catch {
                attributed = nil
            }
            
            DispatchQueue.main.async {
                self.isEditable = false
                self.isScrollEnabled = true
                self.isSelectable = true
                self.dataDetectorTypes = [.link]
                self.attributedText = attributed
                self.textAlignment = .natural
            }
        }
    }
}

extension NSAttributedString {
    /// Converts HTML string into an attributed string with custom font family applied
    static func fromHTML(_ html: String,
                         regularFont: UIFont,
                         boldFont: UIFont? = nil,
                         italicFont: UIFont? = nil,
                         textColor: UIColor = .label) -> NSAttributedString? {
        
        // Step 1: convert to data
        guard let data = html.data(using: .utf8) else { return nil }
        
        // Step 2: parse HTML to attributed string
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        do {
            let raw = try NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
            
            // Step 3: Replace fonts with your Lexend variants
            raw.enumerateAttribute(.font, in: NSRange(location: 0, length: raw.length)) { value, range, _ in
                guard let oldFont = value as? UIFont else { return }
                let traits = oldFont.fontDescriptor.symbolicTraits
                
                if traits.contains(.traitBold), let boldFont = boldFont {
                    raw.addAttribute(.font, value: boldFont, range: range)
                } else if traits.contains(.traitItalic), let italicFont = italicFont {
                    raw.addAttribute(.font, value: italicFont, range: range)
                } else {
                    raw.addAttribute(.font, value: regularFont, range: range)
                }
            }
            
            // Step 4: Ensure correct text color
            raw.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: raw.length))
            
            return raw
            
        } catch {
            print("❌ HTML parse error:", error)
            return nil
        }
    }
}




class PillLabel: UILabel {
    var contentInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + contentInsets.left + contentInsets.right,
                      height: size.height + contentInsets.top + contentInsets.bottom)
    }
}
extension UIButton {
    func loadImage(url: String, placeholder: UIImage? = nil) {
        // Set placeholder if provided
        if let placeholder = placeholder {
            self.setImage(placeholder, for: .normal)
        } else {
            self.setImage(nil, for: .normal)
        }
        
        guard let imageUrl = URL(string: url) else { return }

        // Fetch image asynchronously
        URLSession.shared.dataTask(with: imageUrl) { data, _, error in
            guard let data = data, error == nil,
                  let image = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                self.setImage(image, for: .normal)
            }
        }.resume()
    }
}
extension String {
    func stripHTML() -> String {
        guard let data = self.data(using: .utf8) else { return self }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        let attributedString = try? NSAttributedString(
            data: data,
            options: options,
            documentAttributes: nil
        )

        return attributedString?.string ?? self
    }
}
extension String {
    func to12HourTime() -> String {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "HH:mm:ss"
            inputFormatter.locale = Locale(identifier: "en_US_POSIX")

            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "hh:mm a"
            outputFormatter.locale = Locale(identifier: "en_US_POSIX")

            guard let date = inputFormatter.date(from: self) else {
                return self
            }
            return outputFormatter.string(from: date)
        }
    
    /// converts yyyy-MM-dd type string into dd MMM, yyyy

    func fromyyyyMMddtoDDMMMYYYY() -> String {
           let inputFormatter = DateFormatter()
           inputFormatter.dateFormat = "yyyy-MM-dd"
           inputFormatter.locale = Locale(identifier: "en_US_POSIX")

           let outputFormatter = DateFormatter()
           outputFormatter.dateFormat = "dd MMM, yyyy"
           outputFormatter.locale = Locale(identifier: "en_IN")  // or .current

           guard let date = inputFormatter.date(from: self) else {
               return self
           }
           return outputFormatter.string(from: date)
       }
    
    func fromyyyyMMddtoDDMMM() -> String {
           let inputFormatter = DateFormatter()
           inputFormatter.dateFormat = "yyyy-MM-dd"
           inputFormatter.locale = Locale(identifier: "en_US_POSIX")

           let outputFormatter = DateFormatter()
           outputFormatter.dateFormat = "dd MMM"
           outputFormatter.locale = Locale(identifier: "en_IN")  // or .current

           guard let date = inputFormatter.date(from: self) else {
               return self
           }
           return outputFormatter.string(from: date)
       }
    
    /// converts yyyy-MM-dd type string into dd MM yyyy
    
    func fromyyyyMMddtoDDMMYYYY() -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd-MM-yyyy"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = inputFormatter.date(from: self) else {
            return self // fallback to original if parsing fails
        }
        return outputFormatter.string(from: date)
    }
    
    
    
    /// converts yyyy-dd-MM type string into dd MM yyyy
    
    func toDDMMYYYY() -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-dd-MM"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd-MM-yyyy"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = inputFormatter.date(from: self) else {
            return self // fallback to original if parsing fails
        }
        return outputFormatter.string(from: date)
    }
    
    /// converts yyyy-MM-dd type string into dd MMM yyyy
    func toddMMMyyyy() -> String{
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMM yyyy"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let date = inputFormatter.date(from: self) {
            return outputFormatter.string(from: date)
        } else {
            return self // fallback if parsing fails
        }
    }
    
    func getTimeAgo() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        
        if let sampleDate = formatter.date(from: self) {
            return sampleDate.timeAgo()
        }else{
            return "recent"
        }
    }
        // ADD THIS NEW FUNCTION 👇
            func formatDate() -> String {
                let inputFormatter = DateFormatter()
                inputFormatter.locale = Locale(identifier: "en_US_POSIX")
                inputFormatter.dateFormat = "yyyy-MM-dd"
                
                if let date = inputFormatter.date(from: self) {
                    let outputFormatter = DateFormatter()
                    outputFormatter.dateFormat = "dd MMM yyyy"  // Output: "31 Dec 2025"
                    return outputFormatter.string(from: date)
                }
                
                return self
            }
    }

extension Date {
    func timeAgo() -> String {
        let now = Date()
        let secondsAgo = Int(now.timeIntervalSince(self))
        
//        let minute = 60
//        let hour = 60 * minute
//        let day = 24 * hour
//        let week = 7 * day
//        let month = 30 * day
        
        if secondsAgo < 60 {
            return "just now"
        } else if secondsAgo < 3600 {
            let minutes = secondsAgo / 60
            return minutes == 1 ? "1 min ago" : "\(minutes) mins ago"
        } else if secondsAgo < 86400 {
            let hours = secondsAgo / 3600
            return hours == 1 ? "1 hr ago" : "\(hours) hrs ago"
        } else if secondsAgo < 604800 {
            let days = secondsAgo / 86400
            return days == 1 ? "1 day ago" : "\(days) days ago"
        } else if secondsAgo < 2_592_000 {
            let weeks = secondsAgo / 604800
            return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
        } else if secondsAgo < 31_536_000 {
            let months = secondsAgo / 2_592_000
            return months == 1 ? "1 month ago" : "\(months) months ago"
        } else {
            let years = secondsAgo / 31_536_000
            return years == 1 ? "1 year ago" : "\(years) years ago"
        }
    }
    
    func toddMMYYYY() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let formattedDateString = dateFormatter.string(from: self)
        return formattedDateString
    }
}
func formatEntryFee(_ fee: String) -> String {
    // Convert string to double and format
    if let feeValue = Double(fee) {
        let formattedFee = String(format: "%.2f", feeValue)
        return "₹\(formattedFee)/-"
    } else if fee.isEmpty || fee == "0" || fee == "0.00" {
        return "₹0.00/-"
    } else {
        return "₹\(fee)/-"
    }
}
// MARK:  HEX CODE CONVERTER EXTENSION
// Macha this handles the magic of converting "#123456" to a real Color
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
func handleLogout() {
    let defaults = UserDefaults.standard
    if let appDomain = Bundle.main.bundleIdentifier {
        defaults.removePersistentDomain(forName: appDomain)
        defaults.synchronize()
    }
    UserDefaults.standard.removeObject(forKey: "ACCESSTOKEN")
    DispatchQueue.main.async {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = story.instantiateViewController(identifier: "navbar") as? UINavigationController
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            print("Unable to find a valid window")
            return
        }
        window.rootViewController = loginVC
        window.makeKeyAndVisible()
    }
}
extension UIViewController {

    private var loaderView: UIView? {
        get {
            return objc_getAssociatedObject(self, &loaderKey) as? UIView
        }
        set {
            objc_setAssociatedObject(
                self,
                &loaderKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    func showLoader() {
        DispatchQueue.main.async {
            if self.loaderView != nil { return }

            let loader = UIView(frame: self.view.bounds)
            loader.backgroundColor =
                UIColor.black.withAlphaComponent(0.4)

            let spinner =
                UIActivityIndicatorView(style: .large)
            spinner.center = loader.center
            spinner.color = .white
            spinner.startAnimating()

            loader.addSubview(spinner)
            self.view.addSubview(loader)
            self.view.bringSubviewToFront(loader)

            self.loaderView = loader
        }
    }

    func hideLoader() {
        DispatchQueue.main.async {
            self.loaderView?.removeFromSuperview()
            self.loaderView = nil
        }
    }
}
extension UITextField {
    func addLeftPadding(_ value: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: value, height: 0))
        leftView = paddingView
        leftViewMode = .always
    }
}
extension UIView {
    func addDashedBorder(color: UIColor = .lightGray, lineWidth: CGFloat = 1, cornerRadius: CGFloat = 8, dashPattern: [NSNumber] = [8, 4]) {
        // Remove previous dashed layer if it exists (to prevent stacking)
        self.layer.sublayers?.filter { $0.name == "DashedBorder" }.forEach { $0.removeFromSuperlayer() }

        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "DashedBorder" 
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineDashPattern = dashPattern
        shapeLayer.fillColor = nil
        shapeLayer.frame = self.bounds
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
}
extension UIImageView {
    func loadImage(from url: URL, placeholder: UIImage? = nil) {
        self.image = placeholder
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Image load error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
