//
//  ScienceView.swift
//  MapApp
//
//  Created by George Wang on 10/22/24.
//

import SwiftUI
import MapKit

// CircleData structure to match JSON data
struct CircleData: Identifiable, Decodable {
    let id: Int
    let center_coordinate_lat: Double
    let center_coordinate_lon: Double
    let radius: Double
    let accessibility_score: Double  // New field for accessibility score
    let core_values: CoreValues  // Use CoreValues struct for core values
}

// CoreValues structure to match core values in JSON
struct CoreValues: Decodable {
    let average_degree: Double   // New field for average degree
    let clustering_coefficient: Double  // Clustering coefficient
    let radius: Double           // Radius of the cluster
    let diameter: Double         // Diameter of the cluster
    let average_path_length: Double  // Average path length
    let density: Double          // Density of the cluster
}

// CircleView to display each circle based on CircleData
struct CircleView: View {
    let circle: CircleData
    
    // Function to generate the color based on the accessibility score
    private func color(for score: Double) -> Color {
        // Clamp the score to the range of -1 to 1
        let clampedScore = min(max(score, -1), 1)
        
        // Adjusted desaturation factor for more muted colors
        let desaturationFactor: Double = 0.5 // Lowering this value increases desaturation
        
        // Calculate red and green values based on the score
        let redValue = max(0, (1.0 + clampedScore) * desaturationFactor) // Red decreases as score goes from -1 to 1
        let greenValue = max(0, (1.0 - clampedScore) * desaturationFactor) // Green increases as score goes from -1 to 1

        return Color(red: redValue, green: greenValue, blue: 0.0, opacity: 0.5) // Semi-transparent fill
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color(for: circle.accessibility_score))
                .frame(width: CGFloat(circle.radius / 10), height: CGFloat(circle.radius / 10)) // Adjust size
            
            Circle()
                .stroke(color(for: circle.accessibility_score).opacity(1.0), lineWidth: 2) // Opaque bordershe
                .frame(width: CGFloat(circle.radius / 10), height: CGFloat(circle.radius / 10))
        }
    }
}


// Function to load CircleData from the JSON file
func loadCircleData() -> [CircleData] {
    guard let url = Bundle.main.url(forResource: "datamap", withExtension: "json") else {
        print("Failed to locate datamap.json in bundle.")
        return []
    }
    
    print("Loading data from URL: \(url)")
    
    do {
        let data = try Data(contentsOf: url)
        let decodedData = try JSONDecoder().decode([CircleData].self, from: data)
       
        return decodedData
    } catch {
        print("Error loading data: \(error)")
        return []
    }
}


struct ScienceView: View {
    
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 52.52, longitude: 13.4050),
        span: MKCoordinateSpan(latitudeDelta: 0.0265, longitudeDelta: 0.0265)
    )
    
    @State private var zoomLevel: Double = 0.203 - 0.0265
    @State private var locationReady: Bool = false
    @State private var currentLocation: CLLocationCoordinate2D? = nil
    
    // New states
    @State private var circles: [CircleData] = loadCircleData()
    @State private var selectedCircle: CircleData? = nil
    @State private var showingDetails = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            if locationReady {
                VStack {
                    Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: circles) { circle in
                        MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: circle.center_coordinate_lat, longitude: circle.center_coordinate_lon)) {
                            CircleView(circle: circle)
                            .onTapGesture {
                                selectedCircle = circle
                                showingDetails = true  // Show details when a circle is tapped
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        locationManager.requestLocation()
                    }
                    
                }
                .sheet(isPresented: $showingDetails) {
                    if let selectedCircle = selectedCircle {
                        CircleDetailView(circle: selectedCircle) // New view for details
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .edgesIgnoringSafeArea(.all)
                
            } else {
                VStack {
                    Spacer() // Pushes content to the center vertically

                    Image("Image") // Replace "yourImageName" with the actual image name
                        .resizable()
                        .scaledToFit() // Ensures the image scales appropriately
                        .frame(width: 150, height: 150) // Adjust size if necessary

                    Text("Fetching your location...")
                        .foregroundColor(.white) // White text color
                        .font(.headline) // Optional: you can change the font style
                        .padding(.top, 10) // Optional: padding between the image and the text

                    Spacer() // Fills remaining space after the content
                }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black) // Optional: background color if needed
                    .edgesIgnoringSafeArea(.all) // Optional: make sure it ignores safe area insets
                    .multilineTextAlignment(.center) // Ensure text is centered
            }
            
            // Center Button (Recenter user location)
            Button(action: {
                if let userLocation = locationManager.location {
                    setRegion(userLocation.coordinate, zoom: zoomLevel)
                }
            }) {
                Image(systemName: "location.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            .frame(width: 50, height: 50)
            .position(x: UIScreen.main.bounds.width - 40, y: 80)
            
            // Zoom Slider
            Slider(value: Binding(
                get: { zoomLevel },
                set: { newValue in
                    zoomLevel = newValue
                    updateMapZoomLevel(newValue)
                }
            ), in: 0.05...0.20, step: 0.001)
            .rotationEffect(.degrees(-90))
            .frame(width: 150, height: 30)
            .position(x: UIScreen.main.bounds.width - 40, y: 200)
            .accentColor(.black)
            
            
            
            
            
            
            
        }
        .onAppear {
            locationManager.requestLocation()
            waitForLocation()
        }
        
    }
    
    private func waitForLocation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let userLocation = locationManager.location {
                setRegion(userLocation.coordinate, zoom: zoomLevel)
                locationReady = true // Location fetched, ready to display map
            } else {
                waitForLocation() // Retry until location is fetched
            }
        }
    }
    
    private func updateMapZoomLevel(_ newValue: Double) {
        let maxZoom = 0.203
        let adjustedSpan = maxZoom - newValue
        region.span = MKCoordinateSpan(latitudeDelta: adjustedSpan, longitudeDelta: adjustedSpan)
    }

    private func setRegion(_ coordinate: CLLocationCoordinate2D, zoom: Double) {
        let maxZoom = 0.203
        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: maxZoom - zoomLevel, longitudeDelta: maxZoom - zoomLevel)
        )
        currentLocation = coordinate // Store current location
    }
}

struct CircleDetailView: View {
    let circle: CircleData

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // Title Section
                Text("Cluster Metrics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)

                // Circle ID and Accessibility Score
                Text("ID: \(circle.id)")
                    .font(.headline)
                    .padding(.bottom, 2)
                Text("Accessibility Score: \(String(format: "%.4f", circle.accessibility_score))")
                    .font(.subheadline)
                    .padding(.bottom, 10)

                Divider() // Separator

                // Location Information
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                    Text("Coordinates: \(String(format: "%.4f", circle.center_coordinate_lat)), \(String(format: "%.4f", circle.center_coordinate_lon))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                // Radius
                Text("Radius: \(Int(circle.radius)) meters")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)

                Divider() // Separator

                // Core Values Section
                Text("Core Values")
                    .font(.headline)
                    .padding(.bottom, 5)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Average Degree: \(String(format: "%.2f", circle.core_values.average_degree))")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text("Clustering Coefficient: \(String(format: "%.4f", circle.core_values.clustering_coefficient))")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text("Radius: \(String(format: "%.2f", circle.core_values.radius))")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text("Diameter: \(String(format: "%.2f", circle.core_values.diameter)) meters")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text("Average Path Length: \(String(format: "%.2f", circle.core_values.average_path_length))")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text("Density: \(String(format: "%.4f", circle.core_values.density))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 10)

                Divider() // Separator

                // Download Section
                Text("Download the data:")
                    .font(.headline)
                    .padding(.bottom, 5)

                Text("These data are protected under Creative Commons Non-Commercial License")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)

                VStack(alignment: .leading, spacing: 8) {
                    Link("Download JSON", destination: URL(string: "https://example.com/download/json")!)
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                .padding(.bottom, 10)

                Divider() // Separator

                // Full Map Section
                Text("Full Network Visualization")
                    .font(.headline)
                    .padding(.bottom, 5)

                Image("san-map")  // Replace "mapImage" with the name of your image in the assets catalog
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)
                    .padding(.bottom, 20)

                Spacer()  // Pushes content upwards for spacing
            }
            .padding()
        }
        .navigationTitle("Cluster Metrics")
        .navigationBarTitleDisplayMode(.inline)
    }
}
