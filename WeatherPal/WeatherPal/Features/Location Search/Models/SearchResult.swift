//
//  SearchResult.swift
//  WeatherPal
//
//  Created by Marlon Raskin on 2023-09-30.
//

import MapKit

struct SearchResult: Identifiable, Equatable {
	let id = UUID()
	/// City & State (if applicable)
	let title: String
	/// Country
	let subtitle: String
}

extension SearchResult {
	
	init(_ completion: MKLocalSearchCompletion) {
		self.init(title: completion.title, subtitle: completion.subtitle)
	}
}

extension SearchResult {
	
	var isAirport: Bool {
		title.contains("Airport")
	}
}
