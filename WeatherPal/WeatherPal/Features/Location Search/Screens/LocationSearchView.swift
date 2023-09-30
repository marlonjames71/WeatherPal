//
//  LocationSearchView.swift
//  WeatherPal
//
//  Created by Marlon Raskin on 2023-09-26.
//

import SwiftUI

// Given more time I would show the user a history of their queries.
// This would allow them to get back to the weather for previously searched locations a lot quicker.

struct LocationSearchView: View {
	
	@State private var query = ""
	@State private var searchPresented = false
	// Handling the search for locations using Apple's APIs
	@StateObject private var locationSearchManager = LocationSearchManager()
	@Environment(\.dismiss) var dismiss
	
	let locationSelectionHandler: (LocationResult) -> Void
	
	var body: some View {
		NavigationStack {
			List {
				ForEach(locationSearchManager.searchResults) { result in
					LocationSearchRow(searchResult: result) { selectedLocation in
						// On tap of row:
						locationSelectionHandler(selectedLocation)
						dismiss()
					}
					.environmentObject(locationSearchManager)
				}
			}
			// Trigger the search bar so that it's ready to receive input when the view appears
			.onAppear { searchPresented = true }
			.listStyle(.plain)
			.navigationTitle("Location Search")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar { Button("Dismiss") { dismiss() } }
			.onChange(of: query) { oldValue, newValue in
				if newValue.isEmpty {
					// Clear the table when no text is in the search field
					locationSearchManager.clearResults()
				} else {
					// When search field has text, pass that text to the completer to get locations that best match
					locationSearchManager.addQuery(newValue)
				}
			}
			.searchable(
				text: $query,
				isPresented: $searchPresented,
				placement: .navigationBarDrawer(displayMode: .always),
				prompt: "The city to get the weather for"
			)
		}
	}
}

#Preview {
	LocationSearchView { _ in }
}
