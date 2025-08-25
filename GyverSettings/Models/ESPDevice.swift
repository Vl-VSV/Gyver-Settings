//
//  ESPDevice.swift
//  GyverSettings
//
//  Created by Vlad V on 22.08.2025.
//

import Foundation

struct ESPDevice: Identifiable, Codable {
	let id: UUID

	let name: String
	let ip: String
	let mac: String

	init(
		id: UUID = UUID(),
		name: String,
		ip: String,
		mac: String
	) {
		self.id = id
		self.name = name
		self.ip = ip
		self.mac = mac
	}

	var url: URL? {
		URL(string: "http://\(ip)/")
	}
}
