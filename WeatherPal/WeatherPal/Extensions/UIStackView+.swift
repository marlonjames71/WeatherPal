//
//  UIStackView+.swift
//  WeatherPal
//
//  Created by Marlon Raskin on 2023-09-28.
//

import UIKit

extension UIStackView {
	
	func removeArrangedSubviews() {
		arrangedSubviews.forEach { removeArrangedSubview($0) }
	}
	
	func addArrangedSubviews(_ views: [UIView]) {
		views.forEach { addArrangedSubview($0) }
	}
	
	func addArrangedSubviews(_ views: UIView...) {
		views.forEach { addArrangedSubview($0) }
	}
	
	var contentLayoutMargins: UIEdgeInsets {
		get { layoutMargins }
		set {
			layoutMargins = newValue
			isLayoutMarginsRelativeArrangement = true
		}
	}
}
