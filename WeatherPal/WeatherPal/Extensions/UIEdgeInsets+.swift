//
//  UIEdgeInsets+.swift
//  WeatherPal
//
//  Created by Marlon Raskin on 2023-09-29.
//

import UIKit

extension UIEdgeInsets {
	
	init(horizontal: CGFloat, vertical: CGFloat) {
		self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
	}
	
	init(horizontal: CGFloat) {
		self.init(top: 0, left: horizontal, bottom: 0, right: horizontal)
	}
	
	init(vertical: CGFloat) {
		self.init(top: vertical, left: 0, bottom: vertical, right: 0)
	}
	
	init(allEdges inset: CGFloat) {
		self.init(top: inset, left: inset, bottom: inset, right: inset)
	}
}
