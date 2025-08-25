//
//  ESPCacheManagerImpl.swift
//  GyverSettings
//
//  Created by Vlad V on 25.08.2025.
//

import Foundation

final class ESPCacheManagerImpl: ESPCacheManager {
	private static let devicesKey = "cachedESPDevices"

	func saveDevices(_ devices: [ESPDevice]) throws {
		let data = try JSONEncoder().encode(devices)

		UserDefaults.standard.set(data, forKey: Self.devicesKey)
	}

	func loadDevices() throws -> [ESPDevice] {
		guard let data = UserDefaults.standard.data(forKey: Self.devicesKey) else {
			return []
		}

		let devices = try JSONDecoder().decode([ESPDevice].self, from: data)
		return devices
	}
}

