//
//  LocationSearchRow.swift
//  WeatherPal
//
//  Created by Marlon Raskin on 2023-09-26.
//

import SwiftUI

struct LocationSearchRow: View {
	
	@EnvironmentObject var locationSearchManager: LocationSearchManager
	
	@State private var showingProgressSpinner = false
	@State private var showingNoCoordinateAlert = false
	
	let searchResult: SearchResult
	let onClick: (LocationResult) -> Void
	
	var body: some View {
		Button(action: addLocationResult) {
			HStack {
				VStack(alignment: .leading) {
					Text(searchResult.title)
					
					if !searchResult.subtitle.isEmpty {
						Text(searchResult.subtitle)
							.font(.caption)
							.foregroundColor(.secondary)
					}
				}
				
				Spacer()
				
				// Quickly identify if a location is an airport
				if searchResult.isAirport && !showingProgressSpinner {
					Image(systemName: "airplane")
						.foregroundColor(Color.accentColor)
						.frame(width: 30, height: 30)
				}
				
				if showingProgressSpinner {
					VStack {
						ProgressView()
							.progressViewStyle(.circular)
							.frame(width: 30, height: 30)
					}
				}
			}
			.listRowSeparator(.hidden)
			.clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
			.alert(
				"Could not get the coordinate for this location. This may be due to missing information.",
				isPresented: $showingNoCoordinateAlert
			) {
				Button("OK") {
					showingProgressSpinner = false
					showingNoCoordinateAlert = false
				}
			}
		}
	}
	
	private func addLocationResult() {
		showingProgressSpinner = true
		
		Task {
			let place = "\(searchResult.title), \(searchResult.subtitle)"
			let locationData = await locationSearchManager.coordinateAndCountryCode(for: place)
			
			guard let coordinate = locationData.coordinate else {
				print("Could not get coordinate for given address")
				showingNoCoordinateAlert = true
				return
			}
			
			let result = LocationResult(
				title: place,
				latitude: coordinate.latitude,
				Longitude: coordinate.longitude
			)
			
			onClick(result)
			showingProgressSpinner = false
		}
	}
}

#Preview {
	LocationSearchRow(searchResult: .init(title: "Medellín", subtitle: "Badajoz, Spain"), onClick: { _ in })
}
