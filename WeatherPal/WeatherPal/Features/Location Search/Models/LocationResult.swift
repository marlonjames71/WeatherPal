//
//  LocationResult.swift
//  WeatherPal
//
//  Created by Marlon Raskin on 2023-09-26.
//

import CoreLocation
import Foundation

struct LocationResult: Codable {
	let id: UUID
	let title: String
	let latitude: Double
	let longitude: Double
}

extension LocationResult {
	
	init(title: String, latitude: Double, Longitude: Double) {
		self.id = UUID()
		self.title = title
		self.latitude = latitude
		self.longitude = Longitude
	}
}

extension LocationResult {
	
	var coordinate: CLLocationCoordinate2D {
		.init(latitude: latitude, longitude: longitude)
	}
}
