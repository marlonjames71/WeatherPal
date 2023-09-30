//
//  WeatherService.swift
//  WeatherPal
//
//  Created by Marlon Raskin on 2023-09-26.
//

import CoreLocation
import Foundation


class WeatherService {
	
	// For fetching weather for searched location
	func fetchWeather(using coordinate: CLLocationCoordinate2D) async throws -> WeatherResult {
		guard let url = weatherUrl(for: .coordinate(coordinate)) else { throw WeatherResponseError.badUrl }
		return try await weather(for: url)
	}
	
	// For fetching last location search
	func fetchWeather(using cityID: Int) async throws -> WeatherResult {
		guard let url = weatherUrl(for: .cityID(cityID)) else { throw WeatherResponseError.badUrl }
		return try await weather(for: url)
	}
	
	private func weather(for url: URL) async throws -> WeatherResult {
		let (data, _) = try await URLSession.shared.data(from: url)
		let decodedData = try JSONDecoder().decode(WeatherResult.self, from: data)
		return decodedData
	}
	
	enum SearchMethod {
		case coordinate(CLLocationCoordinate2D)
		case cityID(Int)
	}
	
	private func weatherUrl(for method: SearchMethod) -> URL? {
		let queryItems: [URLQueryItem] = switch method {
		case .coordinate(let coordinate):
			[
				.init(name: "lat", value: "\(coordinate.latitude)"),
				.init(name: "lon", value: "\(coordinate.longitude)"),
				.init(name: "units", value: "imperial"),
				.init(name: "appid", value: "\(APIKeys.apiKey)")
			]
		case .cityID(let cityID):
			[
				.init(name: "id", value: "\(cityID)"),
				.init(name: "units", value: "imperial"),
				.init(name: "appid", value: "\(APIKeys.apiKey)")
			]
		}
		
		var components = URLComponents()
		components.scheme = "https"
		components.host = "api.openweathermap.org"
		components.path = "/data/2.5/weather"
		components.queryItems = queryItems
		
		return components.url
	}
	
	func imageUrl(for iconID: String) -> URL? {
		return URL(string: "https://openweathermap.org/img/wn/\(iconID)@2x.png")
	}
}

extension WeatherService {
	
	enum WeatherResponseError: Error {
		case badUrl
	}
}
