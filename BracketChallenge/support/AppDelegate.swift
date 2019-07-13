//
//  AppDelegate.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/30/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit
import FacebookCore
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
		
		let center = UNUserNotificationCenter.current()
		center.delegate = self
		center.requestAuthorization(options: [.badge, .sound, .alert]) { (granted, error) in
			print("Accepted!")
			DispatchQueue.main.async {
				application.registerForRemoteNotifications()
			}
		}
		
        return true
    }
	
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let scheme = url.scheme, scheme.hasPrefix("fb\(SDKSettings.appId)"), url.host == "authorize" {
            return SDKApplicationDelegate.shared.application(app, open: url, options: options)
        }
        
        return false
    }
    
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		let hexToken = deviceToken.map { String(format: "%02hhx", $0) }.joined()
		print(hexToken)
	}
	
	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		print("Failed to get token, error: \(error)")
	}
}

