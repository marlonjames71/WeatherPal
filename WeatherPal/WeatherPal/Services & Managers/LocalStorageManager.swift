//
//  LocalStorageManager.swift
//  WeatherPal
//
//  Created by Marlon Raskin on 2023-09-30.
//

import Foundation

class LocalStorageManager {
	
	static func getLastQuery() -> Int? {
		UserDefaults.standard.integer(forKey: LocalStorageKeys.lastQuery)
	}
	
	static func saveLastQuery(cityID: Int) {
		UserDefaults.standard.setValue(cityID, forKey: LocalStorageKeys.lastQuery)
	}
}
