//
//  SplashVCOne.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 28/01/26.
//
import UIKit

class SplashVCOne: UIViewController {

    @IBOutlet weak var nextBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func nextBtnTapped(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SplashVCTwo") as! SplashVCTwo
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve  // Smooth transition
        present(vc, animated: true)
    }
}
