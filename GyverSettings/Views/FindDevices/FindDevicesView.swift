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
		ScrollView(showsIndicators: false) {
			Section {
				scannedDevices
			} header: {
				Text("Найденные устройства")
					.font(.title)
					.fontWeight(.semibold)
			}

		}
		.padding()
		.overlay(alignment: .bottom) {
			scanSection
		}
		.toolbar {
			ToolbarItem {
				aboutApp
			}
		}
		.fullScreenCover(item: $viewModel.selectedDevice) { device in
			if let url = device.url {
				SafariView(url: url)
					.ignoresSafeArea()
			}
		}
		.sheet(isPresented: $viewModel.showAboutView) {
			AboutView()
		}
	}

	private var scanSection: some View {
		VStack {
			if case let .scanning(value) = viewModel.status {
				progressBar(value)
			}

			scanButton
		}
	}

	private var scanButton: some View {
		Button {
			viewModel.startScanning()
		} label: {
			HStack {
				Image(systemName: "magnifyingglass")
				Text("Сканировать устройства")
					.fontWeight(.semibold)
			}
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

	@ViewBuilder
	private var scannedDevices: some View {
		if viewModel.status.id == .done && viewModel.foundDevices.isEmpty {
			nothingFound
		} else {
			VStack {
				ForEach(viewModel.foundDevices) {
					deviceCard($0)
				}
			}
			.frame(maxWidth: .infinity)
		}
	}

	private var nothingFound: some View {
		Text("Устройства не найдены")
			.font(.headline)
			.foregroundStyle(.secondary)
			.padding(32)
	}

	private func progressBar(_ progress: Double) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			ProgressView(value: Float(progress), total: 100)
				.progressViewStyle(.linear)
				.tint(.blue)
			Text(
				progress == 0 ?
				"Ожидание сканирования" :
				"Cканирование... \(Int(progress))%"
			)
			.font(.subheadline)
			.foregroundStyle(.secondary)
		}
		.padding()
		.frame(maxWidth: .infinity)
		.cornerRadius(16)
		.shadow(radius: 4, y: 2)
		.padding(.horizontal)
	}

	private func deviceCard(_ device: ESPDevice) -> some View {
		Button {
			viewModel.onDeviceTap(device)
		} label: {
			HStack(spacing: 16) {
				Image(systemName: "wifi.router")
					.font(.title3)
					.foregroundStyle(.blue)

				VStack(alignment: .leading, spacing: 4) {
					Text(device.name)
						.font(.headline)
					Text(device.ip)
						.font(.caption)
						.foregroundStyle(.secondary)
				}

				Spacer()

				Image(systemName: "chevron.right")
			}
			.padding()
			.frame(maxWidth: .infinity, alignment: .leading)
			.background {
				RoundedRectangle(cornerRadius: 20).stroke(style: .init(lineWidth: 2))
					.foregroundStyle(.secondary)
			}
			.padding()
		}
		.buttonStyle(.plain)
	}

	private var aboutApp: some View {
		Button {
			viewModel.showAboutView.toggle()
		} label: {
			Label("О программе", systemImage: "info.circle")
		}
	}
}

#Preview {
	FindDevicesView(viewModel: FindDevicesViewModel())
}
