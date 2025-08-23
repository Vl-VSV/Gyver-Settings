//
//  FindView.swift
//  GyverSettings
//
//  Created by Vlad V on 22.08.2025.
//

import SwiftUI

struct FindDevicesView: View {
	@StateObject var viewModel: FindDevicesViewModel

	var body: some View {
		ScrollView {
			Section {
				scannedDevices
			} header: {
				Text("Найденные устройства")
					.font(.title)
					.fontWeight(.semibold)
			}

		}
		.scrollIndicators(.hidden)
		.padding()
		.overlay(alignment: .bottom) {
			VStack {
				if case let .scanning(value) = viewModel.status {
					progressBar(value)
				}

				scanButton
			}
		}
		.fullScreenCover(item: $viewModel.selectedDevice) { device in
			if let url = device.url {
				SafariView(url: url)
					.ignoresSafeArea()
			}
		}
	}

	private var scanButton: some View {
		Button {
			viewModel.startScanning()
		} label: {
			HStack {
				Image(systemName: "magnifyingglass")
				Text("Сканировать устройства")
			}
			.fontWeight(.semibold)
			.padding(.horizontal, 24)
			.padding(.vertical, 12)
			.buttonStyle(.plain)
			.background {
				Capsule().stroke(style: .init(lineWidth: 2))
			}
			.padding()
			.disabled(viewModel.status.id == .scanning)
		}
	}

	private var scannedDevices: some View {
		VStack {
			ForEach(viewModel.foundDevices) {
				deviceCard($0)
			}
		}
		.frame(maxWidth: .infinity)
	}

	private func progressBar(_ progress: Int) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			ProgressView(value: Float(progress), total: 100)
				.progressViewStyle(.linear)
				.tint(.blue)
			Text(
				progress == 0 ?
				"Ожидание сканирования" :
				"Cканирование... \(progress)%"
			)
			.font(.subheadline)
			.foregroundStyle(.secondary)
		}
		.padding()
		.frame(maxWidth: .infinity)
		.cornerRadius(16)
		.shadow(radius: 4, y: 2)
		.padding()
	}

	private func deviceCard(_ device: ESPDevice) -> some View {
		Button {
			viewModel.onDeviceTap(device)
		} label: {
			HStack(spacing: 16) {
				Image(systemName: "wifi.router")
					.font(.title3)

				VStack(alignment: .leading, spacing: 4) {
					Text(device.name)
						.font(.headline)
					Text(device.ip)
						.font(.caption)
						.foregroundStyle(.secondary)
				}

				Spacer()

				Image(systemName: "chevron.right")
					.foregroundColor(.gray)
					.fontWeight(.bold)
			}
			.padding()
			.frame(maxWidth: .infinity, alignment: .leading)
			.background {
				Capsule().stroke(style: .init(lineWidth: 2))
			}
			.padding()
		}
		.buttonStyle(.plain)
	}
}

#Preview {
	FindDevicesView(viewModel: FindDevicesViewModel())
}
