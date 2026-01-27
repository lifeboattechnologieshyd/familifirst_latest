//
//  FeelPlayerController.swift
//  FamilyFirst
//
//  Created by Lifeboat on 14/01/26.
//

import UIKit
import YouTubeiOSPlayerHelper



class FeelPlayerController: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    

    var selected_feel_item: FeelItem!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = selected_feel_item.title
        topView.addBottomShadow()
        playYouTubeVideo()
    
    }
    func playYouTubeVideo() {
        let videoID = "\(selected_feel_item.youtubeVideo!)".extractYoutubeId()
        
        
        activityIndicator.startAnimating()
        
        playerView.load(withVideoId: videoID ?? "", playerVars: [
            "playsinline": 1,
            "autoplay": 1,
            "mute": 0,
            "controls": 1,
            "modestbranding": 1
        ])
        playerView.delegate = self
        
    }
    
 
    
    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
extension FeelPlayerController: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        activityIndicator.stopAnimating()
         playerView.playVideo()
    }
}
