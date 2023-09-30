//
//  WeatherDisplayViewModel.swift
//  WeatherPal
//
//  Created by Marlon Raskin on 2023-09-25.
//

import Combine
import Foundation

class WeatherDisplayViewModel {
	
	private let weatherService = WeatherService()
	var currentWeather: WeatherResult = .dummyWeather
	
	enum FetchType {
		case newWeather(LocationResult)
		case lastWeather(cityID: Int)
	}
	
	func fetch(_ fetchType: FetchType) {
		Task {
			do {
				let weatherResult = switch fetchType {
				case .newWeather(let location):
					try await self.weatherService.fetchWeather(using: location.coordinate)
				case .lastWeather(let cityID):
					try await weatherService.fetchWeather(using: cityID)
				}
				
				currentWeather = weatherResult
				weatherUpdate.send(true)
				
				if case .newWeather(_) = fetchType {
					LocalStorageManager.saveLastQuery(cityID: weatherResult.id)
				}
				print(weatherResult)
			} catch {
				// Would display an alert letting the user know why the app failed to get the weather
				// by sending the error through.
				weatherUpdate.send(false)
				print("Weather Service Error: \(error)")
			}
		}
	}
	
	// MARK: - Display Properties

	private(set) var screenTitle: String = "☀️ Weather Pal"
	private(set) var searchButtonTitle = "Search for a location"
	private(set) var searchButtonSubtitle = "to see weather for that area"
	
	var currentWeatherIsEmpty: Bool {
		currentWeather == .dummyWeather
	}
	
	var locationName: String { currentWeather.name ?? screenTitle }
	
	var date: String { formatDate(currentWeather.dateTime) }
	
	var iconUrl: URL? {
		guard let iconId = currentWeather.weather.first?.icon else { return nil }
		return weatherService.imageUrl(for: iconId)
	}
	
	var temp: String {
		formatTemp(currentWeather.info.temp)
	}
	
	var feelsLike: String {
		formatTemp(currentWeather.info.feelsLike)
	}
	
	var lowTemp: String {
		formatTemp(currentWeather.info.tempMin)
	}
	
	var highTemp: String {
		formatTemp(currentWeather.info.tempMax)
	}
	
	var sunrise: String {
		time(from: currentWeather.locationInfo.sunrise)
	}
	
	var sunset: String {
		time(from: currentWeather.locationInfo.sunset)
	}
	
	var humidity: String {
		"\(currentWeather.info.humidity)%"
	}
	
	var visibility: String {
		"\(currentWeather.visibility) mi"
	}
	
	var windSpeed: String {
		"\(Int(currentWeather.wind.speed)) mph"
	}
	
	var windGust: String? {
		guard let gust = currentWeather.wind.gust else { return nil }
		return "\(gust)"
	}
	
	var cloudCoverage: String {
		"\(currentWeather.clouds.all)%"
	}
	
	// MARK: - Properties
	
	private var cancellables = Set<AnyCancellable>()
	let weatherUpdate = PassthroughSubject<Bool, Never>()
	
	// MARK: - Helpers & Formatters
	
	private func formatTemp(_ temp: Double) -> String {
		let formatter = MeasurementFormatter()
		
		return formatter.string(from: .init(
			value: Double(Int(temp)),
			unit: UnitTemperature.fahrenheit
		))
	}
	
	private func time(from date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateStyle = .none
		formatter.timeStyle = .short
		
		return formatter.string(from: date)
	}
	
	private func formatDate(_ date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .medium
		
		return formatter.string(from: date)
	}
}
