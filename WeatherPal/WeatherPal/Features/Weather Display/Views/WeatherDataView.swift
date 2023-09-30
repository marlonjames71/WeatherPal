//
//  WeatherDataView.swift
//  WeatherPal
//
//  Created by Marlon Raskin on 2023-09-29.
//

import SnapKit
import UIKit

class WeatherDataView: UIView {
	
	let iconName: String?
	let title: String
	private(set) var value: String {
		didSet { valueLabel.text = value }
	}
	
	init(iconName: String?, title: String, value: String) {
		self.iconName = iconName
		self.title = title
		self.value = value
		
		super.init(frame: .zero)
	}
	
	required init?(coder: NSCoder) {
		fatalError("Use init(iconName:, title:, value:) instead")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		setupViews()
	}
	
	// MARK: - Methods
	
	func updateValue(_ value: String) {
		self.value = value
	}
	
	// MARK: - Views & Layout
	
	private func setupViews() {
		addSubview(hStack)
		hStack.snp.makeConstraints { $0.edges.equalToSuperview() }
		
		iconView.image = UIImage(systemName: iconName ?? "info.circle.fill")
	}
	
	private lazy var hStack: UIStackView = {
		let stack = UIStackView()
		stack.spacing = 8
		stack.distribution = .fill
		stack.addArrangedSubview(iconContainer)
		stack.addArrangedSubview(vStack)
		stack.contentLayoutMargins = .init(allEdges: 8)
		stack.layer.cornerRadius = 8
		stack.layer.cornerCurve = .continuous
		stack.backgroundColor = .systemFill
		
		return stack
	}()
	
	private lazy var vStack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
		stack.axis = .vertical
		stack.spacing = 4
		stack.alignment = .leading
		
		return stack
	}()
	
	private lazy var iconContainer: UIView = {
		let view = UIView()
		view.addSubview(iconView)
		iconView.snp.makeConstraints { $0.leading.trailing.centerY.equalTo(view) }
		
		return view
	}()
	
	private lazy var iconView: UIImageView = {
		let imageView = UIImageView()
		imageView.preferredSymbolConfiguration = .init(hierarchicalColor: .systemTeal)
		imageView.contentMode = .scaleAspectFit
		imageView.snp.makeConstraints { $0.height.width.equalTo(20) }
		return imageView
	}()
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.text = title
		label.font = .preferredFont(forTextStyle: .caption1)
		label.textColor = .secondaryLabel
		
		return label
	}()
	
	private lazy var valueLabel: UILabel = {
		let label = UILabel()
		label.text = value
		label.font = .monospacedDigitSystemFont(ofSize: 17, weight: .regular)
		
		return label
	}()
}
