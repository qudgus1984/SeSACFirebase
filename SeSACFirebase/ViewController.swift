//
//  ViewController.swift
//  SeSACFirebase
//
//  Created by 이병현 on 2022/10/05.
//

import UIKit
import FirebaseAnalytics

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Analytics.logEvent("rejack", parameters: [
          "name": "고래밥",
          "full_text": "안녕하세요",
        ])
        
        Analytics.setDefaultEventParameters([
          "level_name": "Caverns01",
          "level_difficulty": 4
        ])
        
    }


    @IBAction func crashsClicked(_ sender: UIButton) {
    }
}

