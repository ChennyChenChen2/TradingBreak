//
//  LoadingViewController.swift
//  TradingBreak
//
//  Created by Jonathan Chen on 5/27/20.
//  Copyright © 2020 n/a. All rights reserved.
//

import Foundation
import UIKit

class LoadingViewController: UIViewController {
    
    @IBOutlet weak var quoteLabel: UILabel!
    let quotes = [
        "We are only as good as the stocks we trade.",
        "Solution focus.",
        "We become what we consistently do.",
        "What you do every day matters.",
        "Price is what you pay. Value is what you get.",
        "Risk comes from not knowing what you're doing.",
        "Once we realize that imperfect understanding is the human condition there is no shame in being wrong, only in failing to correct our mistakes.",
    ]
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        } set {}
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.bool(forKey: HomeViewController.notificationExistsKey) {
            showHomeVC()
        } else {
            let index = Int(arc4random_uniform(UInt32(quotes.count)))
            let quote = quotes[index]
            
            self.quoteLabel.text = quote
            
            UIView.animate(withDuration: 2.0, animations: {
                self.quoteLabel.alpha = 1
            }) { (_) in
                UIView.animate(withDuration: 5.0, animations: {
                    self.quoteLabel.alpha = 0
                }) { [weak self] (_) in
                    self?.showHomeVC()
                }
            }
        }
    }
    
    private func showHomeVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: HomeViewController.storyboardID) as? HomeViewController
        let navController = CustomNavigationController()
        
        if let vc = vc {
            navController.viewControllers = [vc]
            UIApplication.shared.windows.first?.rootViewController = navController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
}

class CustomNavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        } set {}
    }
}
