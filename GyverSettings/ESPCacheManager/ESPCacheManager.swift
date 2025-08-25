//
//  ESPCacheManager.swift
//  GyverSettings
//
//  Created by Vlad V on 25.08.2025.
//

protocol ESPCacheManager {
	func saveDevices(_ devices: [ESPDevice]) throws
	func loadDevices() throws -> [ESPDevice]
}
