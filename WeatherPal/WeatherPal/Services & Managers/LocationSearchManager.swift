//
//  LocationSearchManager.swift
//  WeatherPal
//
//  Created by Marlon Raskin on 2023-09-25.
//

import Combine
import Foundation
import MapKit

/// Used for searching locations — mainly cities and airports.
class LocationSearchManager: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
	
	@Published var searchResults: [SearchResult] = []
	
	func clearResults() {
		searchResults = []
	}
	
	func addQuery(_ query: String) {
		completer.queryFragment = query
	}
	
	private (set) lazy var completer: MKLocalSearchCompleter = {
		let completer = MKLocalSearchCompleter()
		completer.region = .init(.world)
		completer.resultTypes = [.address, .pointOfInterest]
		completer.pointOfInterestFilter = .init(including: [.airport])
		completer.delegate = self
		return completer
	}()
	
	func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
		let results = completer.results.filter { result in
			// Doesn't allow results that have numbers in the title
			if result.title.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
				return false
			}
			
			// Allows results with numbers in the subtitle only if they're airports
			if 
				result.subtitle.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
				&& !result.title.contains("Airport")
			{ return false }
			
			// Some results would show up such as "Vape Shops" with "Search Nearby" as the subtitle
			// Code below filters those out.
			if 
				result.subtitle == "Search Nearby" 
				|| result.subtitle == "No Results Nearby"
			{ return false }
			
			// Filters out results like "Chick-fil-A" that has an empty subtitle, but
			// allows Copenhagen, Denmark that also has an empty subtitle.
			if 
				result.subtitle.isEmpty 
				&& !result.title.contains(",")
				&& !result.title.contains("Airport")
			{ return false }
			
			let titleComponents = result.title.components(separatedBy: " ")
			if titleComponents.contains(where: excludedSubtitles.contains) {
				return false
			}
			
			return true
		}
		
		let locationSearchResults = results.map(SearchResult.init(_:))
		
		searchResults = locationSearchResults
	}
	
	let excludedSubtitles = [
		"Blvd",
		"St",
		"Cir",
		"Ln",
		"Dr",
		"Loop",
		"Ave",
		"Hwy",
		"Pkwy",
		"Ct",
		"Rd"
	]
}

extension LocationSearchManager {
	
	/// Cleans up the subtitle by removing the specifics of an address to be combined with the title.
	///
	/// Instead of: **1501 Sherman Way, Los Angeles, CA 91505, United States**
	///
	/// You get: **Los Angeles, CA, United States**
	///
	/// Removes both the street address and the zip code (91505 OR 91505-5803)
	///
	private func sanitizeSubtitle(from result: MKLocalSearchCompletion) -> String {
		if result.title.contains("Airport") {
			var stripped = result.subtitle.components(separatedBy: ", ")
			let firstComponent = stripped.removeFirst()
			guard firstComponent.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil else {
				return result.subtitle
			}
			
			let joined = stripped.joined(separator: ", ")
			// Removes the zip code (example: 91505 OR 91505-5803)
			let sanitized = joined.replacing(/\s+\d{5}(\-\d{4})?/, with: "")
			
			return sanitized
		} else {
			return result.subtitle
		}
	}
	
	private func address(from result: MKLocalSearchCompletion) -> String {
		"\(result.title), \(result.subtitle)"
	}
	
	private func displayText(from result: MKLocalSearchCompletion) -> String {
		let subtitle = sanitizeSubtitle(from: result)
		if !subtitle.isEmpty {
			let place = "\(result.title), \(subtitle)"
			return result.title.contains("Airport") ? place : result.title
		} else {
			return result.title
		}
	}
	
	typealias CoordinateAndCountryCode = (coordinate: CLLocationCoordinate2D?, countryCode: String?)
	
	func coordinateAndCountryCode(for place: String) async -> CoordinateAndCountryCode {
		let geocoder = CLGeocoder()
		let placemarks = try? await geocoder.geocodeAddressString(place)
		print(placemarks ?? [])
		guard let placemark = placemarks?.first else { return (nil, nil) }
		
		let coordinate = placemark.location?.coordinate
		let countryCode = placemark.isoCountryCode
		
		return (coordinate, countryCode)
	}
}
