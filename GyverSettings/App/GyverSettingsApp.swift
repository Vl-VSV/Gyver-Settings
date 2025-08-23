//
//  GyverSettingsApp.swift
//  GyverSettings
//
//  Created by Vlad V on 22.08.2025.
//

import SwiftUI

@main
struct GyverSettingsApp: App {
    var body: some Scene {
        WindowGroup {
            FindDevicesView(viewModel: FindDevicesViewModel())
        }
    }
}
