//
//  CalendarTableCell.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 07/03/26.
//

import UIKit
import YouTubeiOSPlayerHelper
import AVFoundation

class CalendarTableCell: UITableViewCell {
    
    @IBOutlet weak var lblPrompt: UILabel!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var lblWriteup: UILabel!
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblBenifit: UILabel!
    
    var videoUrl: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        playerView.isHidden = true
        btnPlay.isHidden = false
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetPlayer()
    }
    
    private func resetPlayer() {
        imgVw.isHidden = false
        btnPlay.isHidden = false
        playerView.isHidden = true
        playerView.stopVideo()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Configure with CalendarData
    func configure(calendarData: CalendarData) {
        
        if let imageUrl = calendarData.image, !imageUrl.isEmpty {
            imgVw.loadImage(url: imageUrl)
        } else {
            imgVw.image = UIImage(named: "placeholder")
        }
        
        let promptText = calendarData.prompt ?? "No prompt available"
        let benefitText = calendarData.benefit ?? "No benefit available"
        let descriptionText = calendarData.description ?? "No description available"
        
        let prompt = madeAttributeString(boldPart: "Prompt:", desc: " \(promptText)")
        let benifit = madeAttributeString(boldPart: "Benefit:", desc: " \(benefitText)")
        
        lblPrompt.numberOfLines = 0
        lblBenifit.numberOfLines = 0
        lblWriteup.numberOfLines = 0
        
        lblPrompt.lineBreakMode = .byWordWrapping
        lblBenifit.lineBreakMode = .byWordWrapping
        lblWriteup.lineBreakMode = .byWordWrapping
        
        lblPrompt.attributedText = prompt
        lblBenifit.attributedText = benifit
        lblWriteup.attributedText = madeAttributeWriteupString(boldPart: "Writeup: ", desc: descriptionText)
        
        videoUrl = calendarData.youtubeVideoURL
    }
    
    // MARK: - Attributed String Helpers
    
    func madeAttributeWriteupString(boldPart: String, desc: String) -> NSMutableAttributedString {
        let boldAttr = NSMutableAttributedString(
            string: boldPart,
            attributes: [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: UIColor.label
            ]
        )

        if let htmlData = desc.data(using: .utf8),
           let htmlAttr = try? NSMutableAttributedString(
                data: htmlData,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
           ) {
            
            let fullRange = NSRange(location: 0, length: htmlAttr.length)
            htmlAttr.addAttributes([
                .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                .foregroundColor: UIColor.label
            ], range: fullRange)
            boldAttr.append(htmlAttr)
        }
        return boldAttr
    }

    func madeAttributeString(boldPart: String, desc: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(
            string: boldPart,
            attributes: [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold)
            ]
        )
        attributedString.append(NSAttributedString(
            string: desc,
            attributes: [
                .font: UIFont.systemFont(ofSize: 16, weight: .regular)
            ]
        ))
        return attributedString
    }
    
    // MARK: - YouTube Helpers
    
    private func extractYoutubeId(from url: String) -> String? {
        if let url = URL(string: url), let host = url.host {
            if host.contains("youtu.be") {
                return url.lastPathComponent
            } else if host.contains("youtube.com"),
                      let queryItems = URLComponents(string: url.absoluteString)?.queryItems {
                return queryItems.first(where: { $0.name == "v" })?.value
            }
        }
        return nil
    }
    
    @IBAction func onClickPlay(_ sender: UIButton) {
        if let url = videoUrl {
            btnPlay.isHidden = true
            playerView.isHidden = false
            imgVw.isHidden = true
            guard let videoID = extractYoutubeId(from: url) else { return }
            playerView.load(withVideoId: videoID, playerVars: ["playsinline": 1, "autoplay": 1])
        }
    }
}
