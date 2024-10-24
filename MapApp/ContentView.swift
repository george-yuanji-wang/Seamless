//
//  ContentView.swift
//  MapApp
//
//  Created by George Wang on 10/20/24.
//
import SwiftUI


struct ContentView: View {
    @State private var selectedTab: Tab = .map

    enum Tab {
        case map, settings, science
    }

    var body: some View {
        VStack(spacing: 0) {
            // Switch between Map, Science, and Settings view
            if selectedTab == .map {
                MapView()
            } else if selectedTab == .science {
                ScienceView() // New view for the science-related content
            } else {
                SettingsView()
            }

            // Bottom navigation bar (Minimalistic black-and-white bar)
            HStack(spacing: 0) {
                // Map Button (Left)
                Button(action: {
                    selectedTab = .map // Switch to the map view
                }) {
                    Image(systemName: "map.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white) // Icon color
                        .padding()
                }
                .frame(maxWidth: .infinity) // Take equal space
                .background(Color.black) // Black background for the button

                // Science Button (Center)
                Button(action: {
                    selectedTab = .science // Switch to the science view
                }) {
                    Image(systemName: "flask.fill") // Science symbol
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white) // Icon color
                        .padding()
                }
                .frame(maxWidth: .infinity) // Take equal space
                .background(Color.black) // Black background for the button

                // Settings Button (Right)
                Button(action: {
                    selectedTab = .settings // Switch to the settings view
                }) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white) // Icon color
                        .padding()
                }
                .frame(maxWidth: .infinity) // Take equal space
                .background(Color.black) // Black background for the button
            }
            .frame(height: 50) // Fixed height for the navigation bar
        }
        .edgesIgnoringSafeArea(.bottom) // Ensure the bar extends to the bottom
    }
}

