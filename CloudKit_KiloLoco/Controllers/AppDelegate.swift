//
//  AppDelegate.swift
//  CloudKit_KiloLoco
//
//  Created by Lucas Costa  on 08/10/19.
//  Copyright © 2019 LucasCosta. All rights reserved.
//

import UIKit
import UserNotifications
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
            
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UNUserNotificationCenter.current().delegate = self
            
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge,.sound,.alert]) { (authorized, error) in
            
            if let error = error as NSError? {
                print("Error - \(error) - \(error.userInfo)")
            }
            
            if authorized {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Entrou")
        completionHandler(.newData)
//        guard let info = userInfo as? [String : AnyObject] else {return}
//        
//        guard let notification = CKQueryNotification(fromRemoteNotificationDictionary: info) else {return}
//        
//        guard let recordID = notification.recordID else {return}
//        
//        if notification.notificationType == .query {
//            NotificationCenter.default.post(name: Notification.Name("cloudKit.newRecord"), object: nil, userInfo: ["recordID" : recordID])
//        }
//        
//        completionHandler(.newData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Entrou")
        completionHandler()
    }


    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

  

}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        guard let userInfo = notification.request.content.userInfo as? [String : AnyObject] else {return}

        guard let queryNotification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo) else {return}
        
        guard let recordID = queryNotification.recordID else {return}
                       
        if queryNotification.notificationType == .query {
            
            if queryNotification.alertLocalizationKey == "CREATE" {
                NotificationCenter.default.post(name: Notification.Name("cloudKit.newRecord"), object: self, userInfo: ["recordID" : recordID, "type" : "Create"])
            } else {
                NotificationCenter.default.post(name: Notification.Name("cloudKit.deleteRecord"), object: self, userInfo: ["recordID" : recordID, "type" : "Delete"])
            }
            
        }

        completionHandler([.alert, .badge, .sound])
    }
    
    
    
}
