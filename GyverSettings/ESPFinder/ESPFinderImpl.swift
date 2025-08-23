//
//  ESPFinderImpl.swift
//  GyverSettings
//
//  Created by Vlad V on 22.08.2025.
//
import SystemConfiguration.CaptiveNetwork
import Foundation


final class ESPFinderImpl: ESPFinder {
	private static let timeout: TimeInterval = 5
	private static let delay: UInt64 = 40_000_000 // 40 ms

	private let decoder = JSONDecoder()

	func discover(
		onDiscover: @escaping (ESPDevice) -> Void,
		onProgress: @escaping (Int) -> Void
	) async throws(ESPFinderError) {
		guard let localIP = getLocalIPAddress() else {
			throw .failedToGetLocalIP
		}

		let ips = generateIPs(baseIP: localIP)

		for (i, ip) in ips.enumerated() {
			try? await Task.sleep(nanoseconds: Self.delay)

			Task.detached {
				if let device = await self.checkDevice(ip: ip) {
					onDiscover(device)
				}
			}

			onProgress(Int(Double(i) / Double(ips.count) * 100))
		}
	}

	private func checkDevice(ip: String) async -> ESPDevice? {
		print("Checking \(ip) ...")

		guard let url = URL(string: "http://\(ip)/settings?action=discover") else { return nil }

		var request = URLRequest(url: url)
		request.timeoutInterval = Self.timeout

		do {
			let (data, response) = try await URLSession.shared.data(for: request)
			guard
				let http = response as? HTTPURLResponse,
					http.statusCode == 200
			else {
				return nil
			}

			let device = try decoder.decode(Device.self, from: data)

			return ESPDevice(from: device, with: ip)
		} catch {
			return nil
		}
	}

	private func generateIPs(baseIP: String, cidr: Int = 24) -> [String] {
		let parts = baseIP.split(separator: ".")

		guard parts.count == 4 else {
			return []
		}

		let prefix = parts[0...2].joined(separator: ".")
		return (1...254).map { "\(prefix).\($0)" }
	}

	private func getLocalIPAddress() -> String? {
		var address: String?

		var ifaddr: UnsafeMutablePointer<ifaddrs>?

		if getifaddrs(&ifaddr) == 0 {
			var ptr = ifaddr

			while ptr != nil {
				defer { ptr = ptr!.pointee.ifa_next }

				let interface = ptr!.pointee

				let addrFamily = interface.ifa_addr.pointee.sa_family

				if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
					let name = String(cString: interface.ifa_name)

					if name == "en0" {
						var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
						getnameinfo(
							interface.ifa_addr,
							socklen_t(interface.ifa_addr.pointee.sa_len),
							&hostname,
							socklen_t(hostname.count),
							nil,
							socklen_t(0),
							NI_NUMERICHOST
						)

						address = String(cString: hostname)
					}
				}
			}

			freeifaddrs(ifaddr)
		}
		return address
	}
}

extension ESPFinderImpl {
	fileprivate struct Device: Decodable {
		let mac: String
		let name: String
		let type: String
	}
}

extension ESPDevice {
	fileprivate init(from device: ESPFinderImpl.Device, with ip: String) {
		self.init(
			name: device.name,
			ip: ip,
			mac: device.mac
		)
	}
}
