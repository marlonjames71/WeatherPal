//
//  NSDirectionalInsets+.swift
//  WeatherPal
//
//  Created by Marlon Raskin on 2023-09-30.
//

import UIKit

extension NSDirectionalEdgeInsets {
	
	init(horizontal: CGFloat, vertical: CGFloat) {
		self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
	}
}
