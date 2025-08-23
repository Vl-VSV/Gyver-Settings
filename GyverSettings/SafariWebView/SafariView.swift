//
//  SafariView.swift
//  GyverSettings
//
//  Created by Vlad V on 22.08.2025.
//


import SwiftUI
import SafariServices

// MARK: - Safari WebView Wrapper
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}