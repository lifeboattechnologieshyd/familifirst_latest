//
//  SplashVCFour.swift
//  FAMILYFIRST
//
//  Created by Lifeboat on 28/01/26.
//
import UIKit

class SplashVCFour: UIViewController {
    
    @IBOutlet weak var nextBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func nextBtnTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToSplashVCFive", sender: self)
    }
    
}


