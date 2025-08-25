//
//  FindDeviceViewModel.swift
//  GyverSettings
//
//  Created by Vlad V on 22.08.2025.
//

import SwiftUI
import Combine

final class FindDevicesViewModel: ObservableObject {
	@Published var status: Status = .initial
	@Published var foundDevices: [ESPDevice] = []

	@Published var selectedDevice: ESPDevice?

	@Published var showAboutView: Bool = false

	private let espFinder: ESPFinder
	private let cacheManager: ESPCacheManager

	init(
		espFinder: ESPFinder = ESPFinderImpl(),
		cacheManager: ESPCacheManager = ESPCacheManagerImpl()
	) {
		self.espFinder = espFinder
		self.cacheManager = cacheManager

		loadDevicesFromCache()
	}

	func startScanning() {
		foundDevices = []
		status = .scanning(progress: 0)

		Task { @MainActor in
			await startSearching()

			status = .done
		}
	}

	func onDeviceTap(_ device: ESPDevice) {
		selectedDevice = device
	}

	@MainActor
	private func startSearching() async {
		do {
			try await espFinder.discover { [weak self] in
				self?.foundDevices.append($0)
			} onProgress: { [weak self] in
				self?.status = .scanning(progress: $0)
			}

			saveDevices()
		} catch {
			print("Error: \(error)")
		}
	}

	private func loadDevicesFromCache() {
		do {
			foundDevices = try cacheManager.loadDevices()
		} catch {
			print("Failed to load cached devices: \(error)")
		}
	}

	private func saveDevices() {
		do {
			try cacheManager.saveDevices(foundDevices)
		} catch {
			print("Failed to save devices: \(error)")
		}
	}
}

extension FindDevicesViewModel {
	enum Status: Identifiable {
		case initial
		case scanning(progress: Double)
		case done

		enum ID {
			case initial
			case scanning
			case done
		}

		var id: ID {
			switch self {
			case .initial: .initial
			case .scanning: .scanning
			case .done: .done
			}
		}
	}
}
