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
            performSegue(withIdentifier: "goToSplashVCTwo", sender: self)
    }
}


