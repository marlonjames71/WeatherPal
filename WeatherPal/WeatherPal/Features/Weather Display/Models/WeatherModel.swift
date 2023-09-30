//
//  WeatherModel.swift
//  WeatherPal
//
//  Created by Marlon Raskin on 2023-09-25.
//

import Foundation

struct WeatherResult {
	let name: String?
	let id: Int
	let coordinate: Coordinate
	let weather: [Weather]
	let info: Info
	let locationInfo: LocationInfo
	let visibility: Int
	let wind: Wind
	let clouds: Clouds
	let rain: Rain?
	let snow: Snow?
	let dateTime: Date
	let timezone: Int
}

// WEATHER RESULT – DECODABLE
extension WeatherResult: Decodable {
	enum CodingKeys: String, CodingKey {
		case name
		case id
		case coordinate = "coord"
		case weather
		case info = "main"
		case locationInfo = "sys"
		case visibility
		case wind
		case clouds
		case rain
		case snow
		case dateTime = "dt"
		case timezone
	}
}

// COORD
extension WeatherResult {
	struct Coordinate: Decodable {
		let latitude: Double
		let longitude: Double
		
		enum CodingKeys: String, CodingKey {
			case latitude = "lat"
			case longitude = "lon"
		}
	}
}

// WEATHER
extension WeatherResult {
	struct Weather: Decodable {
		let id: Int
		let main: String
		let description: String
		let icon: String
	}
}

// LOCATION INFO
extension WeatherResult {
	struct LocationInfo: Decodable {
		let country: String
		let sunrise: Date
		let sunset: Date
	}
}

// MAIN
extension WeatherResult {
	struct Info: Decodable {
		let temp: Double
		let feelsLike: Double
		let tempMin: Double
		let tempMax: Double
		let pressure: Int
		let humidity: Int
		let seaLevel: Int?
		let groundLevel: Int?
		
		enum CodingKeys: String, CodingKey {
			case temp
			case feelsLike = "feels_like"
			case tempMin = "temp_min"
			case tempMax = "temp_max"
			case pressure
			case humidity
			case seaLevel = "sea_level"
			case groundLevel = "grnd_level"
		}
	}
}

// WIND
extension WeatherResult {
	struct Wind: Decodable {
		let speed: Double
		let degrees: Int
		let gust: Double?
		
		enum CodingKeys: String, CodingKey {
			case speed
			case degrees = "deg"
			case gust
		}
	}
}

// CLOUDS
extension WeatherResult {
	struct Clouds: Decodable {
		let all: Int
	}
}

// RAIN
extension WeatherResult {
	struct Rain: Decodable {
		let lastHour: Double
		let lastThreeHours: Double?
		
		enum CodingKeys: String, CodingKey {
			case lastHour = "1h"
			case lastThreeHours = "3h"
		}
	}
}

// SNOW
extension WeatherResult {
	struct Snow: Decodable {
		let lastHour: Double
		let lastThreeHours: Double?
		
		enum CodingKeys: String, CodingKey {
			case lastHour = "1h"
			case lastThreeHours = "3h"
		}
	}
}

extension WeatherResult: Equatable {
	
	static func == (lhs: WeatherResult, rhs: WeatherResult) -> Bool {
		lhs.id == rhs.id
	}
}

// MOCK DATA
extension WeatherResult {
	
	static let dummyWeather: Self = .init(
		name: "",
		id: 0,
		coordinate: .init(
			latitude: 0,
			longitude: 0
		),
		weather: [],
		info: .init(
			temp: 0,
			feelsLike: 0,
			tempMin: 0,
			tempMax: 0,
			pressure: 0,
			humidity: 0,
			seaLevel: nil,
			groundLevel: nil
		),
		locationInfo: .init(
			country: "",
			sunrise: .init(),
			sunset: .init()
		),
		visibility: 0,
		wind: .init(
			speed: 0,
			degrees: 0,
			gust: nil
		),
		clouds: .init(all: 0),
		rain: nil,
		snow: nil,
		dateTime: .init(),
		timezone: 0
	)
	
	static let mockData: String = """
{
  "coord": {
	 "lon": 10.99,
	 "lat": 44.34
  },
  "weather": [
	 {
		"id": 501,
		"main": "Rain",
		"description": "moderate rain",
		"icon": "10d"
	 }
  ],
  "base": "stations",
  "main": {
	 "temp": 298.48,
	 "feels_like": 298.74,
	 "temp_min": 297.56,
	 "temp_max": 300.05,
	 "pressure": 1015,
	 "humidity": 64,
	 "sea_level": 1015,
	 "grnd_level": 933
  },
  "visibility": 10000,
  "wind": {
	 "speed": 0.62,
	 "deg": 349,
	 "gust": 1.18
  },
  "rain": {
	 "1h": 3.16
  },
  "clouds": {
	 "all": 100
  },
  "dt": 1661870592,
  "sys": {
	 "type": 2,
	 "id": 2075663,
	 "country": "IT",
	 "sunrise": 1661834187,
	 "sunset": 1661882248
  },
  "timezone": 7200,
  "id": 3163858,
  "name": "Zocca",
  "cod": 200
}
"""
}
