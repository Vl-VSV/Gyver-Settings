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

	@MainActor
	func discover(
		onDiscover: @escaping (ESPDevice) -> Void,
		onProgress: @escaping (Double) -> Void
	) async throws(ESPFinderError) {
		guard let (localIP, mask) = getLocalIPAddressAndMask() else {
			throw .failedToGetLocalIP
		}

		let ips = generateIPs(baseIP: localIP, subnetMask: mask)

		print("Scanning subnet \(localIP)/\(mask), hosts: \(ips.count)")

		for (i, ip) in ips.enumerated() {
			try? await Task.sleep(nanoseconds: Self.delay)

			Task.detached { @MainActor in
				if let device = await self.checkDevice(ip: ip) {
					onDiscover(device)
				}
			}

			onProgress(Double(i) / Double(ips.count) * 100)
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

	private func generateIPs(baseIP: String, subnetMask: String) -> [String] {
		guard
			let ipAddr = ipv4ToUInt32(baseIP),
			let mask = ipv4ToUInt32(subnetMask)
		else {
			return []
		}

		let network = ipAddr & mask
		let broadcast = network | ~mask

		var ips: [String] = []

		for host in (network+1)..<broadcast {
			ips.append(uInt32ToIPv4(host))
		}

		return ips
	}

	private func ipv4ToUInt32(_ ip: String) -> UInt32? {
		let parts = ip.split(separator: ".").compactMap { UInt32($0) }
		guard parts.count == 4 else { return nil }
		return (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8) | parts[3]
	}

	private func uInt32ToIPv4(_ num: UInt32) -> String {
		return "\(num >> 24 & 0xFF).\(num >> 16 & 0xFF).\(num >> 8 & 0xFF).\(num & 0xFF)"
	}

	private func getLocalIPAddressAndMask() -> (ip: String, mask: String)? {
		var ifaddr: UnsafeMutablePointer<ifaddrs>?
		guard getifaddrs(&ifaddr) == 0 else { return nil }
		defer { freeifaddrs(ifaddr) }

		var ptr = ifaddr
		while ptr != nil {
			let interface = ptr!.pointee
			defer { ptr = interface.ifa_next }

			let addrFamily = interface.ifa_addr.pointee.sa_family
			if addrFamily == UInt8(AF_INET) {
				let name = String(cString: interface.ifa_name)
				if name == "en0" {
					// IP
					var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
					getnameinfo(
						interface.ifa_addr,
						socklen_t(interface.ifa_addr.pointee.sa_len),
						&hostname,
						socklen_t(hostname.count),
						nil, 0,
						NI_NUMERICHOST
					)
					let ip = String(cString: hostname)

					// Маска
					var netmaskName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
					getnameinfo(
						interface.ifa_netmask,
						socklen_t(interface.ifa_netmask.pointee.sa_len),
						&netmaskName,
						socklen_t(netmaskName.count),
						nil, 0,
						NI_NUMERICHOST
					)
					let mask = String(cString: netmaskName)

					return (ip, mask)
				}
			}
		}
		return nil
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
