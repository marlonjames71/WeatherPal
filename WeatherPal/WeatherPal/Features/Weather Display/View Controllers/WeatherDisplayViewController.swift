//
//  WeatherDisplayViewController.swift
//  WeatherPal
//
//  Created by Marlon Raskin on 2023-09-25.
//

import Combine
import Kingfisher
import SnapKit
import SwiftUI
import UIKit

class WeatherDisplayViewController: UIViewController {
	
	// Did some basic layout. However, given more time, I'd add a scrollview
	
	private let viewModel: WeatherDisplayViewModel
	
	// MARK: - Init
	
	init(viewModel: WeatherDisplayViewModel) {
		self.viewModel = viewModel
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("Use init(viewModel:) instead")
	}
	
	// MARK: - Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = viewModel.screenTitle
		
		view.backgroundColor = .systemBackground
		
		viewModel.weatherUpdate
			.receive(on: DispatchQueue.main)
			.sink { [weak self] hasWeather in
				guard let self else { return }
				hasWeather ? self.updateWeatherDisplay() : self.showEmptyState()
		}
		.store(in: &cancellables)
		
		// Also have to check that the id does not equal 0 as that is the id for our mock data.
		// Our mock data is what is used as the current weather default so we don't have to make
		// the weather object optional.
		if let lastQuery = LocalStorageManager.getLastQuery(), lastQuery != 0 {
			viewModel.fetch(.lastWeather(cityID: lastQuery))
		}
	}
	
	// Using viewIsAppearing so I can setup  the views according to the screen's orientation
	// as the screen's geometry will be available here. This is a new API lifecycle method that's
	// really nice and is only calculated once — perfect for setup.
	override func viewIsAppearing(_ animated: Bool) {
		super.viewIsAppearing(animated)
		
		setupViews(sizeClass: traitCollection.verticalSizeClass)
		
		// New API for monitoring trait changes. In this case, I'm only observing
		// changes with the vertical size class so the UI can be updated properly.
		registerForTraitChanges(
			[UITraitVerticalSizeClass.self]
		) { (self: Self, previousTraitCollection: UITraitCollection) in
			self.updateViews(sizeClass: self.traitCollection.verticalSizeClass)
		}
	}
	
	// MARK: - Methods
	
	private func setupViews(sizeClass: UIUserInterfaceSizeClass) {
		let guide = view.safeAreaLayoutGuide
		
		view.addSubview(emptyStateView.view)
		emptyStateView.view.snp.makeConstraints {
			$0.horizontalEdges.equalTo(guide).inset(40)
			$0.centerY.equalToSuperview()
		}
		
		view.addSubview(searchButtonContainer)
		searchButtonContainer.snp.makeConstraints {
			$0.horizontalEdges.bottom.equalTo(guide)
		}
		
		view.addSubview(contentVStack)
		contentVStack.snp.makeConstraints {
			$0.top.horizontalEdges.equalTo(guide)
			$0.bottom.lessThanOrEqualTo(searchButtonContainer)
		}
		
		if viewModel.currentWeatherIsEmpty {
			nestedContentStack.alpha = 0
		}
		
		updateViews(sizeClass: sizeClass)
	}
	
	private func updateViews(sizeClass: UIUserInterfaceSizeClass) {
		nestedContentStack.axis = sizeClass == .regular ? .vertical : .horizontal
		
		searchButton.configuration?.subtitle = sizeClass == .regular ? viewModel.searchButtonSubtitle : ""
	}
	
	private func updateWeatherDisplay() {
		guard !viewModel.currentWeatherIsEmpty else {
			UIView.animate(withDuration: 0.2) { [weak self] in
				self?.nestedContentStack.alpha = 0
				self?.emptyStateView.view.alpha = 1
			}
			
			title = viewModel.screenTitle
			
			return
		}
		
		if let iconUrl = viewModel.iconUrl {
			KF.url(iconUrl)
				.cacheMemoryOnly()
				.fade(duration: 0.25)
				.set(to: iconImageView)
		}
		
		dateLabel.text = viewModel.date
		tempLabel.text = viewModel.temp
		feelsLikeView.updateValue(viewModel.feelsLike)
		lowTempView.updateValue(viewModel.lowTemp)
		highTempView.updateValue(viewModel.highTemp)
		sunriseView.updateValue(viewModel.sunrise)
		sunsetView.updateValue(viewModel.sunset)
		humidityView.updateValue(viewModel.humidity)
		windSpeedView.updateValue(viewModel.windSpeed)
		cloudCoverageView.updateValue(viewModel.cloudCoverage)
		
		UIView.animate(withDuration: 0.2) { [weak self] in
			self?.emptyStateView.view.alpha = 0
			self?.nestedContentStack.alpha = 1
		}
		
		title = viewModel.locationName
	}
	
	private func showEmptyState() {
		UIView.animate(withDuration: 0.2) { [weak self] in
			self?.contentVStack.alpha = 0
			self?.emptyStateView.view.alpha = 1
		}
	}
	
	private func searchButtonTapped(_ action: UIAction) {
		// Using SwiftUI for search
		let viewController = UIHostingController(rootView: LocationSearchView { location in
			self.viewModel.fetch(.newWeather(location))
		})
		present(viewController, animated: true)
	}
	
	// MARK: - View Properties
	
	private lazy var emptyStateView: UIViewController = {
		let viewController = UIHostingController(rootView: EmptyStateView())
		return viewController
	}()
	
	private lazy var contentVStack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [
			mainTempStack,
			nestedContentStack
		])
		stack.axis = .vertical
		stack.spacing = Specs.stackSpacing
		stack.contentLayoutMargins = .init(allEdges: Specs.edgeMargin)
		
		return stack
	}()
	
	private lazy var nestedContentStack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [
			contentGroupOne,
			contentGroupTwo
		])
		// axis is being set right before the layout occurs in order to use the trait's size class
		stack.spacing = Specs.stackSpacing
		stack.distribution = .fillEqually
		
		return stack
	}()
	
	private lazy var contentGroupOne: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [
			feelsLikeView,
			highLowStack,
			sunriseSunsetStack
		])
		stack.axis = .vertical
		stack.spacing = Specs.stackSpacing
		
		return stack
	}()
	
	private lazy var contentGroupTwo: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [
			humidityView,
			windSpeedView,
			cloudCoverageView
		])
		stack.axis = .vertical
		stack.spacing = Specs.stackSpacing
		
		return stack
	}()
	
	private lazy var mainTempStack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [
			iconAndTempStack,
			dateLabel
		])
		
		stack.axis = .vertical
		stack.alignment = .leading
		
		return stack
	}()
	
	private lazy var iconAndTempStack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [
			iconImageView,
			tempLabel
		])
		
		return stack
	}()
	
	private lazy var dateLabel: UILabel = {
		let label = UILabel()
		label.font = .preferredFont(forTextStyle: .callout)
		label.textColor = .secondaryLabel
		return label
	}()
	
	private lazy var iconImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		
		imageView.snp.makeConstraints { $0.height.width.equalTo(40) }
		
		return imageView
	}()
	
	private lazy var tempLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 28, weight: .bold, width: .standard)
		return label
	}()
	
	private lazy var feelsLikeView: WeatherDataView = {
		let view = WeatherDataView(iconName: "thermometer.medium", title: "Feels Like", value: "")
		return view
	}()
	
	private lazy var highLowStack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [lowTempView, highTempView])
		stack.distribution = .fillEqually
		stack.spacing = Specs.stackSpacing
		return stack
	}()
	
	private lazy var lowTempView: WeatherDataView = {
		let view = WeatherDataView(iconName: "arrowtriangle.down.circle.fill", title: "Low", value: "")
		return view
	}()
	
	private lazy var highTempView: WeatherDataView = {
		let view = WeatherDataView(iconName: "arrowtriangle.up.circle.fill", title: "High", value: "")
		return view
	}()
	
	private lazy var sunriseSunsetStack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [sunriseView, sunsetView])
		stack.distribution = .fillEqually
		stack.spacing = Specs.stackSpacing
		return stack
	}()
	
	private lazy var sunriseView: WeatherDataView = {
		let view = WeatherDataView(iconName: "sunrise.fill", title: "Sunrise", value: "")
		return view
	}()
	
	private lazy var sunsetView: WeatherDataView = {
		let view = WeatherDataView(iconName: "sunset.fill", title: "Sunset", value: "")
		return view
	}()
	
	private lazy var humidityView: WeatherDataView = {
		let view = WeatherDataView(iconName: "humidity", title: "Humidity", value: "")
		return view
	}()
	
	private lazy var windSpeedView: WeatherDataView = {
		let view = WeatherDataView(iconName: "wind", title: "Wind Speed", value: "")
		return view
	}()
	
	private lazy var cloudCoverageView: WeatherDataView = {
		let view = WeatherDataView(iconName: "cloud.fill", title: "Cloud Coverage", value: "")
		return view
	}()
	
	private lazy var searchButton: UIButton = {
		var configuration = UIButton.Configuration.borderedTinted()
		configuration.title = viewModel.searchButtonTitle
		configuration.image = UIImage(systemName: "location.magnifyingglass")
		configuration.imagePadding = Specs.stackSpacing
		configuration.cornerStyle = .capsule
		configuration.contentInsets = .init(horizontal: Specs.edgeMargin, vertical: Specs.stackSpacing)
		configuration.subtitle = viewModel.searchButtonSubtitle
		
		let action = UIAction(handler: searchButtonTapped)
		
		let button = UIButton(configuration: configuration, primaryAction: action)
		
		return button
	}()
	
	private lazy var searchButtonContainer: UIView = {
		let view = UIView()
		view.addSubview(searchButton)
		searchButton.snp.makeConstraints { $0.verticalEdges.centerX.equalToSuperview() }
		
		return view
	}()
	
	// MARK: - Properties
	
	private var cancellables = Set<AnyCancellable>()
}

// MARK: - Specs

extension WeatherDisplayViewController {
	
	enum Specs {
		static let stackSpacing: CGFloat = 8
		static let edgeMargin: CGFloat = 20
	}
}

// MARK: - Empty State View

struct EmptyStateView: View {
	
	var body: some View {
		ContentUnavailableView(
			"No weather to display.",
			systemImage: "cloud.sun.fill",
			description: Text("Search for a location you want to see the weather for.")
		)
	}
}
