//
//  ViewController.swift
//  TradingBreak
//
//  Created by Jonathan Chen on 5/20/20.
//  Copyright © 2020 n/a. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let resetNotification = Notification.Name("resetNotification")
    static let notificationTapped = Notification.Name("notificationTapped")
}

enum AlarmStatus {
    case activated
    case deactivated
    case error(String)
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var switchStatusLabel: UILabel!
    @IBOutlet weak var statusSwitch: UISwitch!
    @IBOutlet weak var successLabel: UILabel!
    
    static let storyboardID = "homeVC"
    static let notificationExistsKey = "notificationExists"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Timer.requestNotificationPermission()
        
        self.navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(respondToNotification), name: Notification.Name.notificationTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resetNotification(_:)), name: Notification.Name.resetNotification, object: nil)
        
        if UserDefaults.standard.bool(forKey: HomeViewController.notificationExistsKey) {
            UserDefaults.standard.set(false, forKey: HomeViewController.notificationExistsKey)
            respondToNotification()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let nextAlarmDate = UserDefaults.standard.value(forKey: Timer.alarmStatusKey)
        
        if let date = nextAlarmDate as? Date {
            if date.compare(Date()) == .orderedAscending {
                // expired alarm, clear storage and turn off switch
                UserDefaults.standard.set(nil, forKey: Timer.alarmStatusKey)
                statusSwitch.isOn = false
            } else {
                statusSwitch.isOn = true
            }
        } else {
            statusSwitch.isOn = false
        }
        
        self.switchStatusLabel.text = statusSwitch.isOn ? "On" : "Off"
    }
    
    @objc private func resetNotification(_ notification: NSNotification) {
        guard let reset = notification.userInfo?["reset"] as? NSNumber else { return }
        updateAlarm(reset.boolValue)
    }
    
    @objc private func respondToNotification() {
        if let _ = self.navigationController?.topViewController as? HomeViewController {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: TemperatureViewController.storyboardID)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func switchChanged(_ sender: Any) {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] (settings) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized {
                    let activate = self.statusSwitch.isOn
                    self.switchStatusLabel.text = activate ? "On" : "Off"
                    self.updateAlarm(activate)
                } else {
                    self.statusSwitch.isOn = false
                    
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    
                    let alert = UIAlertController(title: "Notifications have been disabled.", message: "If you would like to enable notifications, please navigate to the settings app to enable them.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in

                    }))
                    
                    alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }))
                    
                    DispatchQueue.main.async {
                        self.present(alert, animated: false, completion: nil)
                    }
                }
            }
        }
    }
    
    func updateAlarm(_ activate: Bool) {
        if activate {
            Timer.scheduleAlarm { [weak self] (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        // Show error
                        self?.flashStatus(.error(error))
                        self?.statusSwitch.isOn = false
                        return
                    }
                    
                    // Show success alert
                    self?.flashStatus(.activated)
                    self?.statusSwitch.isOn = true
                    self?.switchStatusLabel.text = "On"
                }
            }
        } else {
            UserDefaults.standard.set(false, forKey: HomeViewController.notificationExistsKey)
            
            DispatchQueue.main.async {
                Timer.cancelAlarms()
                self.flashStatus(.deactivated)
                self.statusSwitch.isOn = false
                
                self.switchStatusLabel.text = "Off"
            }
        }
    }
    
    func flashStatus(_ status: AlarmStatus) {
        var message: String
        switch status {
        case .activated:
            message = "Your alarm has been activated."
        case .deactivated:
            message = "Your alarm has been deactivated."
        case .error(let description):
            message = "There was an error scheduling the alarm:\n\(description)"
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.successLabel.text = message
            
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.successLabel.alpha = 1
            }) { (_) in
                UIView.animate(withDuration: 5.0) { [weak self] in
                    self?.successLabel.alpha = 0
                }
            }
        }
    }
}

