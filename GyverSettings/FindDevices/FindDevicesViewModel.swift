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

	private let espFinder: ESPFinder

	init(
		espFinder: ESPFinder = ESPFinderImpl()
	) {
		self.espFinder = espFinder
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
			try await espFinder.discover { @MainActor [weak self] in
				self?.foundDevices.append($0)
			} onProgress: { @MainActor [weak self] in
				self?.status = .scanning(progress: $0)
			}
		} catch {
			print("Error: \(error)")
		}
	}
}

extension FindDevicesViewModel {
	enum Status: Identifiable {
		case initial
		case scanning(progress: Int)
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
