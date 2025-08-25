//
//  AboutView.swift
//  GyverSettings
//
//  Created by Vlad V on 25.08.2025.
//


import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 30) {
			image

            header

            description

			Spacer()

            footer
        }
        .padding()
    }

	private var image: some View {
		Image(systemName: "dot.radiowaves.left.and.right")
			.resizable()
			.scaledToFit()
			.frame(width: 80, height: 80)
			.foregroundColor(.accentColor)
			.padding(.top, 40)
	}

	private var header: some View {
		VStack(spacing: 4) {
			Text("Gyver Settings")
				.font(.title)
				.fontWeight(.bold)
			Text("Версия 1.0")
				.font(.subheadline)
				.foregroundColor(.secondary)
		}
	}

	private var description: some View {
		Text(.init(Constants.appDescription))
		.multilineTextAlignment(.leading)
		.padding(.horizontal)

	}

	private var footer: some View {
		VStack(spacing: 8) {
			Text(.init(Constants.author))
		}
		.font(.footnote)
		.multilineTextAlignment(.center)
	}
}

#Preview {
	AboutView()
}
