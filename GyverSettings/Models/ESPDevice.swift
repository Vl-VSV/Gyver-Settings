//
//  ESPDevice.swift
//  GyverSettings
//
//  Created by Vlad V on 22.08.2025.
//

import Foundation

struct ESPDevice: Identifiable, Equatable {
	let id = UUID()

	let name: String
	let ip: String
	let mac: String

	var url: URL? {
		URL(string: "http://\(ip)/")
	}
}
