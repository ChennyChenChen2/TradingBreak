//
//  TemperatureViewController.swift
//  TradingBreak
//
//  Created by Jonathan Chen on 5/27/20.
//  Copyright © 2020 n/a. All rights reserved.
//

import Foundation
import UIKit

struct Message {
    let title: String
    let subtitle: String
}

class TemperatureViewController: UIViewController {
    
    static let storyboardID = "temperatureVC"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageStack: UIStackView!
    @IBOutlet weak var buttonStack: UIStackView!
    
    var checkedCount = 0 {
        didSet {
            if checkedCount == messages.count {
                UIView.animate(withDuration: 1.0) { [weak self] in
                    self?.buttonStack.alpha = 1
                }
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private let messages = [
    Message(title: "Feeling", subtitle: "Am I calm or am I worked up?"),
    Message(title: "Thinking", subtitle: "Am I focused or am I distracted?"),
    Message(title: "Action", subtitle: "Am I planned or am I reactive?")
    ]
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        for message in messages {
            let stack = makeStack(for: message)
            self.messageStack.addArrangedSubview(stack)
        }
        
        for button in buttonStack.arrangedSubviews {
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.cornerRadius = 5.0
        }
        
        animate()
    }
    
    func animate() {
        UIView.animate(withDuration: 1.0, animations: { [weak self] in
            self?.titleLabel.alpha = 1.0
        }) { [weak self] (_) in
            guard let self = self else { return }

            self.animateMessage(0)
        }
    }
    
    func animateMessage(_ index: Int) {
        if index < self.messageStack.arrangedSubviews.count {
            let stack = self.messageStack.arrangedSubviews[index]
            UIView.animate(withDuration: 1.0, animations: {
                stack.alpha = 1
            }) { [weak self] (_) in
                self?.animateMessage(index + 1)
            }
        }
    }
    
    private func makeStack(for message: Message) -> UIStackView {
        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.alpha = 0
        vStack.distribution = .equalSpacing
        vStack.spacing = 5.0
        
        let titleStack = UIStackView()
        titleStack.axis = .horizontal
        titleStack.spacing = 5.0
        titleStack.distribution = .fillProportionally
        titleStack.alignment = .center
        
        let checkmark = UIButton()
        checkmark.setImage(#imageLiteral(resourceName: "Unchecked"), for: .normal)
        checkmark.addTarget(self, action: #selector(checkmarkPressed(_:)), for: .touchUpInside)
        
        let titleLabel = UILabel().messageStyle()
        titleLabel.text = message.title
        titleLabel.numberOfLines = 0
        
        titleStack.addArrangedSubview(checkmark)
        titleStack.addArrangedSubview(titleLabel)
        
        let subtitleStack = UIStackView()
        subtitleStack.axis = .horizontal
        
        let subtitleLabel = UILabel().messageStyle()
        subtitleLabel.text = "       \(message.subtitle)"
        subtitleLabel.numberOfLines = 0
        subtitleStack.addArrangedSubview(subtitleLabel)
        
        vStack.addArrangedSubview(titleStack)
        vStack.addArrangedSubview(subtitleStack)
        
        return vStack
    }
    
    @objc private func checkmarkPressed(_ sender: UIButton) {
        checkedCount += 1
        sender.setImage(#imageLiteral(resourceName: "Checked"), for: .normal)
        sender.isEnabled = false
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        let dict = ["reset": true]
        NotificationCenter.default.post(name: Notification.Name.resetNotification, object: nil, userInfo: dict)
    }
    
    @IBAction func handsOffButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        let dict = ["reset": false]
        NotificationCenter.default.post(name: Notification.Name.resetNotification, object: nil, userInfo: dict)
    }
}

extension UILabel {
    func messageStyle() -> UILabel {
        self.font = UIFont(name: "Avenir Next", size: 16)!
        self.textColor = .white
        self.textAlignment = .left
        return self
    }
}
