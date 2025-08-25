//
//  ESPFinder.swift
//  GyverSettings
//
//  Created by Vlad V on 22.08.2025.
//

protocol ESPFinder {
	/// Найти все девайсы в локальной сети
	func discover(
		onDiscover: @escaping (ESPDevice) -> Void,
		onProgress: @escaping (Double) -> Void
	) async throws(ESPFinderError)
}
