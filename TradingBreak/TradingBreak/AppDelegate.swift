//
//  AppDelegate.swift
//  TradingBreak
//
//  Created by Jonathan Chen on 5/20/20.
//  Copyright © 2020 n/a. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        NotificationCenter.default.post(name: Notification.Name.notificationTapped, object: nil)
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        checkNotifications()
    }
    
    private func checkNotifications() {
        let nextAlarmDate = UserDefaults.standard.value(forKey: TradingTimer.alarmStatusKey)
        
        if let date = nextAlarmDate as? Date {
            if date.compare(Date()) == .orderedAscending {
                // expired alarm, clear storage and turn off switch
                UserDefaults.standard.set(nil, forKey: TradingTimer.alarmStatusKey)
                NotificationCenter.default.post(name: Notification.Name.notificationTapped, object: nil, userInfo: nil)
            }
        }
        
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                if settings.authorizationStatus != .authorized {
                    UserDefaults.standard.set(nil, forKey: TradingTimer.alarmStatusKey)
                    let dict = ["reset": false]
                    NotificationCenter.default.post(name: Notification.Name.resetNotification, object: nil, userInfo: dict)
                }
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        UserDefaults.standard.set(true, forKey: HomeViewController.notificationExistsKey)
        NotificationCenter.default.post(name: Notification.Name.notificationTapped, object: nil)
        
        completionHandler()
    }
}
