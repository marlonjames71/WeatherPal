//
//  WeatherSearchViewController.swift
//  WeatherPal
//
//  Created by Marlon Raskin on 2023-09-25.
//

import UIKit

class WeatherSearchViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupNavigationBar()
		setupView()
	}
	
	// MARK: - View Properties
	
	private lazy var searchController: UISearchController = {
		let searchController = UISearchController(searchResultsController: nil)
		searchController.delegate = self
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.automaticallyShowsCancelButton = true
		searchController.hidesNavigationBarDuringPresentation = true
		searchController.searchBar.placeholder = "The city to search weather for"
		
		return searchController
	}()
	
	// MARK: - Setup
	
	private func setupNavigationBar() {
		title = "☀️ Weather Pal"
		
		navigationItem.searchController = searchController
		navigationController?.navigationItem.hidesSearchBarWhenScrolling = false
		navigationController?.navigationBar.prefersLargeTitles = true
	}
	
	private func setupView() {
		view.backgroundColor = .systemBackground
	}
}

// MARK: - Extensions

extension WeatherSearchViewController: UISearchResultsUpdating {
	
	func updateSearchResults(for searchController: UISearchController) {
		print(searchController.isActive)
	}
}

extension WeatherSearchViewController: UISearchControllerDelegate {}
