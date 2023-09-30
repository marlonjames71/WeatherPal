//
//  AppDelegate.swift
//  WeatherPal
//
//  Created by Marlon Raskin on 2023-09-25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		// Making sure decoding works
#if DEBUG
		let jsonData = WeatherResult.mockData.data(using: .utf8)!
		let result = try! JSONDecoder().decode(WeatherResult.self, from: jsonData)
		print("\(#file) – Testing decoding...\n\nDecoded Mock Data:\n\(result)")
#endif
		
		return true
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

