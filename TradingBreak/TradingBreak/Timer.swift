//
//  Timer.swift
//  TradingBreak
//
//  Created by Jonathan Chen on 5/26/20.
//  Copyright © 2020 n/a. All rights reserved.
//

import Foundation
import UserNotifications

enum Period {
    case morning
    case tomorrowMorning
    case afternoon
}

class Timer {
    static let alarmStatusKey = "alarmStatusKey"
    
    class func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (success, error) in
            if let error = error {
                print("error? \(error.localizedDescription)")
            }
        }
    }
    
    static var nextAlarmString: String? {
        guard let date = UserDefaults.standard.value(forKey: alarmStatusKey) as? Date else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy hh:mm:ssa"
        
        return formatter.string(from: date)
    }
    
    class func cancelAlarms() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UserDefaults.standard.set(nil, forKey: alarmStatusKey)
    }
    
    class func scheduleAlarm(_ completion: @escaping (String?) -> ()) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: Date())
        let hour = components.hour!
        var fireDate: Date?
        if hour < 10 {
            fireDate = Timer.randomTime(for: .morning)
        } else if hour >= 10 && hour < 13 {
            fireDate = Timer.randomTime(for: .afternoon)
        } else {
            fireDate = Timer.randomTime(for: .tomorrowMorning)
        }
        
        if let date = fireDate {
            let content = UNMutableNotificationContent()
            content.title = "A Trading Break"
            content.body = "Time for a trading break!"
            content.sound = UNNotificationSound(named: UNNotificationSoundName("NYSEBell.wav"))
            
            let components = calendar.dateComponents([.hour, .minute, .second], from: date)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
               if error != nil {
                    completion(error?.localizedDescription)
               }
                
                UserDefaults.standard.set(date, forKey: alarmStatusKey)
                completion(nil)
            }
        } else {
            completion("Invalid date used. Try again.")
        }
    }
    
    class func randomTime(for period: Period) -> Date? {
        #if DEBUG
        return Date().addingTimeInterval(10)
        #endif
        
// FOR DEBUGGING
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MM/dd/yyyy hh:mm:ss a"
        
        let calendar = Calendar.current
        switch period {
        case .tomorrowMorning:
            guard let initial = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: Date()),
                let start = calendar.date(byAdding: .day, value: 1, to: initial) else { return nil }
            let interval = Double(arc4random_uniform(90*60)) as TimeInterval
            
            return start.addingTimeInterval(interval)
        case .morning:
            guard let start = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) else { return nil }
            let interval = Double(arc4random_uniform(90*60))
            return start.addingTimeInterval(interval)
        case .afternoon:
            guard let start = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: Date()) else { return nil }
            let interval = Double(arc4random_uniform(120*60))
            return start.addingTimeInterval(interval)
        }
    }
}
