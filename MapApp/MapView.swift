//
//  MapView.swift
//  MapApp
//
//  Created by George Wang on 10/20/24.
//
import SwiftUI
import MapKit
import UIKit
import PDFKit

// Menu item model
struct MenuItem: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String // Icon system name (SF Symbols)
    let description: String // Info text for the ⓘ symbol
    var isChecked: Bool
}

struct FacilityCondition {
    var operationalStatus: Double = 1.0 // 100% by default
    var maintenanceStatus: Double = 0.8 // 100% by default
    var userSatisfaction: Double = 1.0 // 100% by default
}

// Map annotation model
struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let tag: String
    let iconName: String
    let backgroundColor: Color
    var condition: FacilityCondition? = nil // Optional custom condition
}

struct StationConnection: Identifiable, Codable {
    var id = UUID()
    let station1: String
    let station2: String
    let lat1: Double
    let lon1: Double
    let lat2: Double
    let lon2: Double
    let color: String
}

struct MapItem: Identifiable {
    var id = UUID()
    var stop: GTFSStop? = nil
    var connection: StationConnection? = nil
}

struct AccessibilityServices {
    var wheelchairAccess: Bool
    var elevatorAvailable: Bool
    var audioSignals: Bool
    var tactilePaving: Bool
    var disabledParking: Bool
    var accessibleRestroom: Bool
    var ramps: Bool
}


// Modified DetailView with Self-Report Section that includes Gauges
struct DetailView_item: View {
    var item: MapAnnotationItem
    
    // If no specific condition is provided, fall back to default values (100%)
    var condition: FacilityCondition {
        return item.condition ?? FacilityCondition() // Defaults to 100% if nil
    }

    // Self-report inputs
    @State private var physicalConditionRating: Int = 2  // Physical Condition Rating
    @State private var functionalityRating: Int = 2  // Functionality Rating
    @State private var easeOfUseRating: Int = 2  // Ease of Use Rating
    @State private var maintenanceRating: Int = 2  // Maintenance Rating
    @State private var userComment: String = ""  // User input for self-report
    @State private var showSubmissionAlert = false  // Submission alert flag

    let ratingOptions = ["Poor", "Fair", "Good", "Excellent"] // Clickable rating options
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // Facility Icon and Name
                HStack {
                    // Icon with colored background, black border, and white fill
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(item.backgroundColor)
                            .frame(width: 40, height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                        
                        Image(systemName: item.iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                    }
                    
                    // Facility Name/Tag
                    VStack(alignment: .leading) {
                        Text(item.tag)
                            .font(.headline)
                        Text("Category: Accessibility Facility")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()

                // Location Information
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                    Text("Location: \(item.coordinate.latitude), \(item.coordinate.longitude)") // Display coordinates
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Divider()
                    .padding(.vertical, 5)

                // Condition Metrics with Gauges
                Text("Condition Metrics")
                    .font(.headline)

                // Operational Status with gauge aligned to the right
                HStack(alignment: .center) {
                    // Operational Status Label on the left
                    Text("Operational Status")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading) // Align text to the left

                    // Gauge on the right
                    Gauge(value: condition.operationalStatus, in: 0...1) {
                        // No label
                    } currentValueLabel: {
                        Text("\(Int(condition.operationalStatus * 100))%")
                            .foregroundColor(.primary)
                    }
                    .gaugeStyle(ConditionGaugeStyle()) // Apply the custom style
                    .frame(width: 50, height: 50) // Small size
                    .frame(maxWidth: .infinity, alignment: .trailing) // Align gauge to the right
                }

                // Maintenance Status with gauge aligned to the right
                HStack(alignment: .center) {
                    // Maintenance Status Label on the left
                    Text("Maintenance History")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading) // Align text to the left

                    // Gauge on the right
                    Gauge(value: condition.maintenanceStatus, in: 0...1) {
                        // No label
                    } currentValueLabel: {
                        Text("\(Int(condition.maintenanceStatus * 100))%")
                            .foregroundColor(.primary)
                    }
                    .gaugeStyle(ConditionGaugeStyle())
                    .frame(width: 50, height: 50) // Small size
                    .frame(maxWidth: .infinity, alignment: .trailing) // Align gauge to the right
                }
                
                // User Satisfaction with gauge aligned to the right
                HStack(alignment: .center) {
                    // User Satisfaction Label on the left
                    Text("User Satisfaction")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading) // Align text to the left

                    // Gauge on the right
                    Gauge(value: condition.userSatisfaction, in: 0...1) {
                        // No label
                    } currentValueLabel: {
                        Text("\(Int(condition.userSatisfaction * 100))%")
                            .foregroundColor(.primary)
                    }
                    .gaugeStyle(ConditionGaugeStyle())
                    .frame(width: 50, height: 50) // Small size
                    .frame(maxWidth: .infinity, alignment: .trailing) // Align gauge to the right
                }

                Divider()
                    .padding(.vertical, 5)

                // Self-Report Section (Compact, No Gauges)
                Text("Self-Report Condition")
                    .font(.headline)
                    .padding(.top)

                // Physical Condition Rating (Clickable Options)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Physical Condition")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Picker("Physical Condition", selection: $physicalConditionRating) {
                        ForEach(0..<ratingOptions.count) { index in
                            Text(ratingOptions[index]).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle()) // Clickable segment options
                }
                .padding(.vertical, 5)

                // Functionality Rating (Clickable Options)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Functionality")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Picker("Functionality", selection: $functionalityRating) {
                        ForEach(0..<ratingOptions.count) { index in
                            Text(ratingOptions[index]).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle()) // Clickable segment options
                }
                .padding(.vertical, 5)

                // Ease of Use Rating (Clickable Options)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Ease of Use")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Picker("Ease of Use", selection: $easeOfUseRating) {
                        ForEach(0..<ratingOptions.count) { index in
                            Text(ratingOptions[index]).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle()) // Clickable segment options
                }
                .padding(.vertical, 5)

                // Maintenance Rating (Clickable Options)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Maintenance")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Picker("Maintenance", selection: $maintenanceRating) {
                        ForEach(0..<ratingOptions.count) { index in
                            Text(ratingOptions[index]).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle()) // Clickable segment options
                }
                .padding(.vertical, 5)

                // Comment Text Field
                VStack(alignment: .leading) {
                    Text("Leave a comment:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    TextField("Enter your comments here", text: $userComment)
                            .padding()                        // Padding inside the text field
                            .background(Color.gray.opacity(0.2)) // Light grey background
                            .cornerRadius(8)                   // Rounded corners
                            .foregroundColor(.black)           // White text color for readability
                            .padding(.top, 5)
                    
                     
                }
                .padding(.vertical, 5)

                // Submit Button
                Button(action: {
                    // Handle submission logic here
                    showSubmissionAlert = true
                }) {
                    Text("Submit Report")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .alert(isPresented: $showSubmissionAlert) {
                    Alert(
                        title: Text("Report Submitted"),
                        message: Text("Thank you for submitting your feedback!"),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .padding(.top, 10)

                Spacer() // Pushes content to the top
            }
            .padding()
        }
    }
}


struct DetailView_stop: View {
    var stop: GTFSStop

    // Define route colors
    let route_colors: [String: String] = [
        "J Church": "F4D03F",      // Warm Yellow
        "K Ingleside": "5DADE2",   // Soft Blue
        "L Taraval": "AF7AC5",     // Light Purple
        "M Ocean View": "58D68D",  // Fresh Green
        "N Judah": "3498DB",       // Sky Blue
        "T Third Street": "E74C3C" // Soft Red
    ]
    
    // Accessibility services available for each stop
    let accessibilityServices: [String: AccessibilityServices] = [
        "Embarcadero": AccessibilityServices(
            wheelchairAccess: true, elevatorAvailable: true, audioSignals: false, tactilePaving: true,
            disabledParking: false, accessibleRestroom: false, ramps: true),
        "Montgomery": AccessibilityServices(
            wheelchairAccess: false, elevatorAvailable: true, audioSignals: true, tactilePaving: false,
            disabledParking: false, accessibleRestroom: true, ramps: false),
        // Add more stations
    ]

    // Star rating for each stop
    @State private var rating = 4  // Initial rating (out of 5)
    
    // PDF documents for each stop
    let stopPDFs: [String: String] = [
        "Embarcadero": "embarcadero-station-map", // The PDF file should be added to your app bundle
        "Montgomery": "montgomery-station-map"    // Add more stops and their associated PDFs
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) { // Minimal spacing between sections
            
            // Stop Name (Title)
            Text(stop.stop_name)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 10) // Minimal padding at the top
                .padding(.bottom, 5)

            // Coordinates Section
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                Text("Coordinates: \(String(format: "%.4f", stop.latitude)), \(String(format: "%.4f", stop.longitude))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Divider()
                .padding(.vertical, 5)

            // Routes Section
            Text("Routes:")
                .font(.headline)

            // Dynamic route icons
            HStack(spacing: 5) {
                ForEach(parseRoutes(stop.routes), id: \.self) { route in
                    let colorHex = route_colors[route] ?? "000000"
                    let letter = String(route.prefix(1)) // Get the first letter (J, K, L, etc.)
                    ZStack {
                        Circle()
                            .fill(Color(hex: colorHex))
                            .frame(width: 30, height: 30) // Reduced circle size for route icons
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                            )
                        Text(letter)
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                }
            }
            
            Divider()
                .padding(.vertical, 5)

            // Accessibility Rating
            Text("Accessibility Rating:")
                .font(.headline)

            HStack {
                ForEach(1..<6) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .foregroundColor(star <= rating ? .yellow : .gray)
                        .onTapGesture {
                            rating = star // Update the rating
                        }
                }
            }

            Divider()
                .padding(.vertical, 5)

            // Accessibility Services
            Text("Accessibility Services:")
                .font(.headline)
            
            // Fetch services for the stop
            if let services = accessibilityServices[stop.stop_name] {
                // Single row for all accessibility services with smaller icons
                HStack(spacing: 10) { // Reduced spacing to fit all icons in one row
                    accessibilityIcon(name: "figure.roll", isAvailable: services.wheelchairAccess)    // Wheelchair access
                    accessibilityIcon(name: "arrow.up.arrow.down.circle", isAvailable: services.elevatorAvailable) // Elevator
                    accessibilityIcon(name: "speaker.wave.3.fill", isAvailable: services.audioSignals) // Audio signals
                    accessibilityIcon(name: "road.lanes", isAvailable: services.tactilePaving) // Tactile paving
                    accessibilityIcon(name: "car.fill", isAvailable: services.disabledParking)        // Disabled parking
                    accessibilityIcon(name: "toilet.fill", isAvailable: services.accessibleRestroom)  // Accessible restroom
                    accessibilityIcon(name: "triangle.fill", isAvailable: services.ramps)             // Ramps
                }
            } else {
                Text("No accessibility information available.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Divider()
                .padding(.vertical, 5)

            // Station PDF (Dynamically handled based on stop)
            Text("Station PDF:")
                .font(.headline)

            // Fetch PDFs from the dictionary based on the stop name
            if let pdfName = stopPDFs[stop.stop_name], let pdfURL = Bundle.main.url(forResource: pdfName, withExtension: "pdf"), let pdfDocument = PDFDocument(url: pdfURL) {
                PDFViewWrapper(pdfDocument: pdfDocument)
                    .frame(height: 300) // Adjust the height of the PDF viewer
                    .cornerRadius(10)
            } else {
                Text("No PDF available for this stop.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }


            // Report/Complaint Button with Exclamation Icon
            VStack {
                HStack {
                    Spacer() // Center the icon horizontally
                    Button(action: {
                        // Action for report or complaint (handle logic here)
                    }) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.red) // Red color for the exclamation mark
                    }
                    Spacer() // Center the icon horizontally
                }
                
                // Grey text explaining the button
                Text("Report any issues or concerns with accessibility facilities at this station.")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            .padding(.top, 10) // Add padding above the icon
            .padding(.bottom, 20) // Padding at the bottom of the sheet
        }
        .padding(.horizontal)
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
    // Helper function to create icons based on availability
    private func accessibilityIcon(name: String, isAvailable: Bool) -> some View {
        ZStack {
            Circle()
                .fill(isAvailable ? Color.green : Color.gray) // Green for available, gray for unavailable
                .frame(width: 30, height: 30) // Smaller circle size to fit in one row
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: 2) // Black border
                )
            Image(systemName: name)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18) // Smaller icon size
                .foregroundColor(.black) // Always black for the icons
        }
    }
    
    // Helper function to parse routes and return an array of route names
    private func parseRoutes(_ routes: String) -> [String] {
        return routes.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
}





// MapView
struct MapView: View {
    

    let stopsPath = "/Users/georgeilli/Library/Developer/CoreSimulator/Devices/C77AC966-D988-4BAA-8207-BB119299152A/data/Containers/Bundle/Application/31648888-22FB-4688-9FBC-B6D6051161F1/MapApp.app/stops.txt"
    let tripsPath = "/Users/georgeilli/Library/Developer/CoreSimulator/Devices/C77AC966-D988-4BAA-8207-BB119299152A/data/Containers/Bundle/Application/31648888-22FB-4688-9FBC-B6D6051161F1/MapApp.app/trips.txt"
    let routesPath = "/Users/georgeilli/Library/Developer/CoreSimulator/Devices/C77AC966-D988-4BAA-8207-BB119299152A/data/Containers/Bundle/Application/31648888-22FB-4688-9FBC-B6D6051161F1/MapApp.app/routes.txt"
    let shapesPath = "/Users/georgeilli/Library/Developer/CoreSimulator/Devices/C77AC966-D988-4BAA-8207-BB119299152A/data/Containers/Bundle/Application/31648888-22FB-4688-9FBC-B6D6051161F1/MapApp.app/shapes.txt"
    
    
    
    
    
    @State private var stops: [GTFSStop] = []
    @State private var selectedStop: GTFSStop?
    @State private var selectedItem: MapAnnotationItem?
    @State private var showStopsAndRoute = false
    @StateObject private var viewModel = StationConnectionViewModel()

    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        //34.0699° N, 118.4438° W
        //52.5200° N, 13.4050° E
        center: CLLocationCoordinate2D(latitude: 52.52, longitude: 13.4050),
        span: MKCoordinateSpan(latitudeDelta: 0.0265, longitudeDelta: 0.0265)
    )
    
    @State private var zoomLevel: Double = 0.123 - 0.0265
    @State private var showMenu = false
    @State private var menuOffset: CGFloat = 0
    @State private var radiusMultiplier: Double = 1.0 // Default to 1 mile
    
    @State private var locationReady: Bool = false
    
    // State to store map annotations from API results
    @State private var apiResults: [MapAnnotationItem] = []
    @State private var apiStatusMessage: String = "Waiting for API calls..."
    
    // Timer for refreshing the API call every 10 minutes
    @State private var refreshTimer: Timer? = nil
    
    // Store user's current location
    @State private var currentLocation: CLLocationCoordinate2D? = nil


    
    
    // Menu items with toggles
    @State private var menuItems = [
        MenuItem(name: "Tactile Paving", iconName: "road.lanes", description: "Tactile Paving at Hazardous Places", isChecked: false),
        MenuItem(name: "Disabled Parking Spaces", iconName: "car.fill", description: "Disabled Parking Spaces", isChecked: false),
        MenuItem(name: "Wheelchair-accessible Public Toilets", iconName: "figure.roll", description: "Accessible Public Toilets", isChecked: false),
        MenuItem(name: "Ramps", iconName: "triangle.fill", description: "Wheelchair Ramps", isChecked: false),
        MenuItem(name: "Elevators/Lifts", iconName: "arrow.up.arrow.down.circle", description: "Elevators", isChecked: false),
        MenuItem(name: "Accessible Public Transportation Stops", iconName: "bus", description: "Accessible Bus/Train Stops", isChecked: false),
        MenuItem(name: "Audio Traffic Signals", iconName: "figure.walk.circle.fill", description: "Accessible Crosswalks", isChecked: false),
        MenuItem(name: "Emergency Phones", iconName: "phone.fill", description: "Emergency Phones", isChecked: false),
        MenuItem(name: "Accessible Building Entrances", iconName: "door.left.hand.open", description: "Accessible Building Entrances", isChecked: false),
        MenuItem(name: "Hearing Loops", iconName: "ear.fill", description: "Hearing Loops", isChecked: false),
        MenuItem(name: "Sign Language Services", iconName: "hands.sparkles.fill", description: "Sign Language Services", isChecked: false),
        MenuItem(name: "Accessible Hospitals", iconName: "cross.case.fill", description: "Emergency Rooms", isChecked: false)
    ]
    
    init() {
            // This code runs during view initialization
            if let fileURL = Bundle.main.url(forResource: "stops", withExtension: "json") {
                do {
                    // Read the data from the file
                    let data = try Data(contentsOf: fileURL)
                    
                    // Decode the data into an array of GTFSStop
                    let decodedStops = try JSONDecoder().decode([GTFSStop].self, from: data)
                    
                    // Modifying the @State property directly in init (not recommended)
                    self._stops = State(initialValue: decodedStops)
                    
                    //print("The stops are: \(stops)")
                    
                } catch {
                    print("Error loading or decoding JSON: \(error)")
                }
            } else {
                print("File not found")
            }
    }
    

    
    // Define radius globally (1 mile)
    let radius: Double = 1609.34

    var body: some View {
        ZStack(alignment: .leading) {
            
            
            if locationReady {
                
               
                if !showStopsAndRoute {
                    Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, annotationItems: apiResults) { item in
                        MapAnnotation(coordinate: item.coordinate) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(item.backgroundColor)
                                    .frame(width: 25, height: 25)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.black, lineWidth: 2)
                                    )
                                Image(systemName: item.iconName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.white)
                            }
                            .onTapGesture {selectedItem = item}
                        }
                    }
                    .sheet(item: $selectedItem) { item in
                        DetailView_item(item: item)
                    }
                    .edgesIgnoringSafeArea(.all)
                    
                    
                    
                } else {
                    // Second Map: Map showing stops and route lines
                    ZStack {
                        
                        
     
                        Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, annotationItems: viewModel.stops) { stop in
                                // Render annotations for stops
                            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: stop.latitude, longitude: stop.longitude)) {
                                ZStack {
                                    // Background rectangle with sectionalized colors using HStack
                                    let routeColors = getRouteColors(for: stop)
                                    
                                    let numberOfRoutes = routeColors.count
                                    let baseSize: CGFloat = 25.0 // Base size for a single route
                                    let additionalSizeFactor: CGFloat = 5.0 // Increase size by this factor for each additional route
                                    let dynamicSize = baseSize + CGFloat(max(0, numberOfRoutes - 1)) * additionalSizeFactor // Dynamic size
                                    
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.clear) // Clear fill to show the background HStack colors
                                        .frame(width: dynamicSize, height: dynamicSize)
                                        .overlay(
                                            HStack(spacing: 0) {
                                                ForEach(0..<numberOfRoutes, id: \.self) { index in
                                                    Color(hex: routeColors[index]) // Fill each section with hex color
                                                        .frame(width: dynamicSize / CGFloat(numberOfRoutes), height: dynamicSize) // Adjust size
                                                }
                                            }
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(Color.black, lineWidth: 2) // Black border around the entire rectangle
                                        )
                                    
                                    // Train icon in the center
                                    Image(systemName: "tram.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: dynamicSize * 0.6, height: dynamicSize * 0.6) // Icon scales with the rectangle
                                        .foregroundColor(.black)
                                }
                                .onTapGesture {
                                    selectedStop = stop // Trigger action on tap
                                }
                                
                                
                            }
                        }
                        .sheet(item: $selectedStop) { stop in
                            DetailView_stop(stop: stop) // Pass the selected stop and image
                        }
                        .blendMode(.multiply)
                        .edgesIgnoringSafeArea(.all)
                        .onAppear {
                            viewModel.loadConnections()  // Load the connections and stops
                            
                        }
                        
                       
                        
                    }
                    
                    
                }
                

                
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

            
            



            // Menu background - Only visible when menu is shown
            if showMenu {
                VStack(alignment: .leading, spacing: 15) {
                    Color.black
                        .frame(width: 200)
                        .edgesIgnoringSafeArea(.vertical)
                        .overlay(
                            VStack(alignment: .leading, spacing: 20) {
                                
                                Spacer()
                                
                                ForEach($menuItems) { $menuItem in
                                    HStack {
                                        // Icon with colored background and black border
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(menuItem.isChecked ? getBackgroundColor(for: menuItem.name) : Color.clear) // Only color the background when checked
                                                .frame(width: 25, height: 25) // Slightly smaller box
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 5)
                                                        .stroke(Color.black, lineWidth: 2)
                                                )
                                            
                                            Image(systemName: menuItem.iconName)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 15, height: 15) // Smaller icon size
                                                .foregroundColor(.white)
                                        }

                                        // Item Name (clickable to toggle)
                                        Text(menuItem.description)
                                            .foregroundColor(menuItem.isChecked ? .green : .white)
                                            .font(.system(size: 14))
                                            .onTapGesture {
                                                // Toggle color when clicked
                                                menuItem.isChecked.toggle()
                                                toggleMenuItem(itemName: menuItem.name, isChecked: menuItem.isChecked)
                                            }

                                        
                                    }
                                
                                    .background(menuItem.isChecked ? Color.black.opacity(0.2) : Color.clear) // Highlight when checked
                                    .cornerRadius(10)
                                }
                                
                                
                                Spacer() // Pushes slider to the bottom of the menu
                                                    
                                                    // Slider at the bottom
                                VStack(alignment: .center) {
                                    Spacer()
                                    // "Radius Adjustment" text label
                                    Text("Radius Adjustment")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .center) // Center the text horizontally
                                        .padding(.bottom, 5) // Small gap between title and slider

                                    // Slider and tick marks
                                    VStack {
                                        ZStack {
                                            // Slider positioned at the center
                                            Slider(value: $radiusMultiplier, in: 0.5...2.0, step: 0.5)
                                                .frame(width: 150) // Adjust the slider width
                                                .accentColor(.green)
                                                .onChange(of: radiusMultiplier) { newValue in
                                                    refreshAll() // Call refreshAll() when value changes
                                                }
                                        }

                                        // Tick marks aligned beneath the slider
                                        HStack {
                                            Text("0.5")
                                                .foregroundColor(.white)
                                                .font(.system(size: 12))
                                            Spacer()
                                            Text("1.0")
                                                .foregroundColor(.white)
                                                .font(.system(size: 12))
                                            Spacer()
                                            Text("1.5")
                                                .foregroundColor(.white)
                                                .font(.system(size: 12))
                                            Spacer()
                                            Text("2.0")
                                                .foregroundColor(.white)
                                                .font(.system(size: 12))
                                        }
                                        .frame(width: 150) // Match the slider width
                                    }
                                    
                                    Text("(miles)")
                                    .foregroundColor(.white)
                                    .font(.system(size: 12))
                                    .frame(maxWidth: .infinity, alignment: .center) // Center horizontally

                                }.frame(maxWidth: .infinity, alignment: .center) // Center everything horizontally
                                    .position(x: 90, y: 50)
                               
                                
                                
                                
                            }
                            .frame(maxHeight: .infinity, alignment: .bottom)
                    
                        )
                }
                .transition(.move(edge: .leading))
            }

            
   
            

            // Menu Button that slides to the right and dissolves into the menu
            Button(action: {
                withAnimation(.easeInOut) {
                    showMenu.toggle()
                    menuOffset = showMenu ? 200 : 0
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 50, height: 50)

                    Image(systemName: showMenu ? "xmark" : "line.horizontal.3")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                }
            }
            .offset(x: menuOffset)
            .position(x: 40, y: 15)

            // Center Button (Recenter user location)
            Button(action: {
                if let userLocation = locationManager.location {
                    setRegion(userLocation.coordinate, zoom: zoomLevel)
                    
                    for menuItem in menuItems {
                                if menuItem.isChecked {
                                    triggerAPICall(itemName: menuItem.name)
                                }
                            }
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

            //Toggle transit map
            Button(action: {
                showStopsAndRoute.toggle() // Toggle between maps
            }) {
                Image(systemName: showStopsAndRoute ? "globe.americas" : "tram.fill")
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
            .position(x: UIScreen.main.bounds.width - 40, y: 15) // Adjust position as needed

            
            
            // Zoom Slider
            Slider(value: Binding(
                get: { zoomLevel },
                set: { newValue in
                    zoomLevel = newValue
                    updateMapZoomLevel(newValue)
                }
            ), in: 0.05...0.12, step: 0.001)
            .rotationEffect(.degrees(-90))
            .frame(width: 150, height: 30)
            .position(x: UIScreen.main.bounds.width - 40, y: 200)
            .accentColor(.black)
        }
        .onAppear {
            locationManager.requestLocation()
            waitForLocation() // Wait for location before showing the map
            startRefreshTimer() // Start the shared refresh timer
       
        }
    }
    

    

    
   
    private func updateMapZoomLevel(_ newValue: Double) {
        let maxZoom = 0.123
        let adjustedSpan = maxZoom - newValue
        region.span = MKCoordinateSpan(latitudeDelta: adjustedSpan, longitudeDelta: adjustedSpan)
    }

    private func setRegion(_ coordinate: CLLocationCoordinate2D, zoom: Double) {
        let maxZoom = 0.123
        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: maxZoom - zoomLevel, longitudeDelta: maxZoom - zoomLevel)
        )
        currentLocation = coordinate // Store current location
    }

    // Shared refresh timer for the circle and API calls
    private func startRefreshTimer() {
        refreshTimer?.invalidate() // Invalidate the old timer if it exists
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 600, repeats: true) { _ in
            print("Refreshing API calls and circle...")
            refreshAll()
        }
    }

    // Function to refresh the circle and API data
    private func refreshAll() {
        let adjustedRadius = radiusMultiplier * 1609.34
        if let currentLocation = locationManager.location {
            setRegion(currentLocation.coordinate, zoom: zoomLevel)
        }
        
        // Trigger all toggled API calls
        for menuItem in menuItems {
            if menuItem.isChecked {
                triggerAPICall(itemName: menuItem.name) // API call already uses adjustedRadius
            }
        }
    }



    // Handles the toggling of each menu item and triggers API calls based on the item name
    private func toggleMenuItem(itemName: String, isChecked: Bool) {
        if isChecked {
            // When toggled on, start the API call and refresh every 10 minutes
            triggerAPICall(itemName: itemName)
        } else {
            // When toggled off, remove markers of this type
            removeMarkers(for: itemName)
        }
    }

    
    // Function to handle API results and update the map with annotations
    private func handleAPIResults(_ results: [[String: Any]], tag: String) {
        var newLocations: [MapAnnotationItem] = []
        
        for result in results {
            if let lat = result["lat"] as? Double,
               let lon = result["lon"] as? Double {
                let location = MapAnnotationItem(
                    coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                    tag: tag,
                    iconName: getIconName(for: tag),
                    backgroundColor: getBackgroundColor(for: tag) // Provide background color
                )

                newLocations.append(location)
            }
        }
        
        // Append to existing apiResults to avoid overwriting other types
        apiResults += newLocations
    }
    
    // Trigger an API call based on the item name
    private func triggerAPICall(itemName: String) {
        print("Triggering API call for \(itemName)...")
        apiStatusMessage = "Fetching data for \(itemName)..."
        
        // Calculate the adjusted radius for each call
        let adjustedRadius = radiusMultiplier * 1609.34
        
        switch itemName {
        case "Tactile Paving":
            getTactilePaving(lat: region.center.latitude, lon: region.center.longitude, radius: adjustedRadius) { result in
                switch result {
                case .success(let data):
                    let elements = data["elements"] as? [[String: Any]] ?? []
                    handleAPIResults(elements, tag: "Tactile Paving")
                    apiStatusMessage = "\(elements.count) Tactile Paving locations found."
                case .failure(let error):
                    apiStatusMessage = "Error fetching Tactile Paving: \(error.localizedDescription)"
                }
            }
            
        case "Disabled Parking Spaces":
            getDisabledParking(lat: region.center.latitude, lon: region.center.longitude, radius: adjustedRadius) { result in
                switch result {
                case .success(let data):
                    let elements = data["elements"] as? [[String: Any]] ?? []
                    handleAPIResults(elements, tag: "Disabled Parking Spaces")
                    apiStatusMessage = "\(elements.count) Disabled Parking Spaces found."
                case .failure(let error):
                    apiStatusMessage = "Error fetching Disabled Parking Spaces: \(error.localizedDescription)"
                }
            }
            
        case "Wheelchair-accessible Public Toilets":
            getAccessibleToilets(lat: region.center.latitude, lon: region.center.longitude, radius: adjustedRadius) { result in
                switch result {
                case .success(let data):
                    let elements = data["elements"] as? [[String: Any]] ?? []
                    handleAPIResults(elements, tag: "Wheelchair-accessible Public Toilets")
                    apiStatusMessage = "\(elements.count) Wheelchair-accessible Toilets found."
                case .failure(let error):
                    apiStatusMessage = "Error fetching Wheelchair-accessible Toilets: \(error.localizedDescription)"
                }
            }
            
        case "Ramps":
            getRamps(lat: region.center.latitude, lon: region.center.longitude, radius: adjustedRadius) { result in
                switch result {
                case .success(let data):
                    let elements = data["elements"] as? [[String: Any]] ?? []
                    handleAPIResults(elements, tag: "Ramps")
                    apiStatusMessage = "\(elements.count) Ramps found."
                case .failure(let error):
                    apiStatusMessage = "Error fetching Ramps: \(error.localizedDescription)"
                }
            }
            
        case "Elevators/Lifts":
            getElevators(lat: region.center.latitude, lon: region.center.longitude, radius: adjustedRadius) { result in
                switch result {
                case .success(let data):
                    let elements = data["elements"] as? [[String: Any]] ?? []
                    handleAPIResults(elements, tag: "Elevators/Lifts")
                    apiStatusMessage = "\(elements.count) Elevators found."
                case .failure(let error):
                    apiStatusMessage = "Error fetching Elevators: \(error.localizedDescription)"
                }
            }
            
        case "Accessible Public Transportation Stops":
            getAccessibleStops(lat: region.center.latitude, lon: region.center.longitude, radius: adjustedRadius) { result in
                switch result {
                case .success(let data):
                    let elements = data["elements"] as? [[String: Any]] ?? []
                    handleAPIResults(elements, tag: "Accessible Public Transportation Stops")
                    apiStatusMessage = "\(elements.count) Accessible Public Transportation Stops found."
                case .failure(let error):
                    apiStatusMessage = "Error fetching Accessible Public Transportation Stops: \(error.localizedDescription)"
                }
            }
            
        case "Audio Traffic Signals":
            getAudioTrafficSignals(lat: region.center.latitude, lon: region.center.longitude, radius: adjustedRadius) { result in
                switch result {
                case .success(let data):
                    let elements = data["elements"] as? [[String: Any]] ?? []
                    handleAPIResults(elements, tag: "Audio Traffic Signals")
                    apiStatusMessage = "\(elements.count) Audio Traffic Signals found."
                case .failure(let error):
                    apiStatusMessage = "Error fetching Audio Traffic Signals: \(error.localizedDescription)"
                }
            }
            
        case "Emergency Phones":
            getEmergencyPhones(lat: region.center.latitude, lon: region.center.longitude, radius: adjustedRadius) { result in
                switch result {
                case .success(let data):
                    let elements = data["elements"] as? [[String: Any]] ?? []
                    handleAPIResults(elements, tag: "Emergency Phones")
                    apiStatusMessage = "\(elements.count) Emergency Phones found."
                case .failure(let error):
                    apiStatusMessage = "Error fetching Emergency Phones: \(error.localizedDescription)"
                }
            }
            
        case "Accessible Building Entrances":
            getAccessibleEntrances(lat: region.center.latitude, lon: region.center.longitude, radius: adjustedRadius) { result in
                switch result {
                case .success(let data):
                    let elements = data["elements"] as? [[String: Any]] ?? []
                    handleAPIResults(elements, tag: "Accessible Building Entrances")
                    apiStatusMessage = "\(elements.count) Accessible Building Entrances found."
                case .failure(let error):
                    apiStatusMessage = "Error fetching Accessible Building Entrances: \(error.localizedDescription)"
                }
            }
            
        case "Hearing Loops":
            getHearingLoops(lat: region.center.latitude, lon: region.center.longitude, radius: adjustedRadius) { result in
                switch result {
                case .success(let data):
                    let elements = data["elements"] as? [[String: Any]] ?? []
                    handleAPIResults(elements, tag: "Hearing Loops")
                    apiStatusMessage = "\(elements.count) Hearing Loops found."
                case .failure(let error):
                    apiStatusMessage = "Error fetching Hearing Loops: \(error.localizedDescription)"
                }
            }
            
        case "Sign Language Services":
            getSignLanguageServices(lat: region.center.latitude, lon: region.center.longitude, radius: adjustedRadius) { result in
                switch result {
                case .success(let data):
                    let elements = data["elements"] as? [[String: Any]] ?? []
                    handleAPIResults(elements, tag: "Sign Language Services")
                    apiStatusMessage = "\(elements.count) Sign Language Services found."
                case .failure(let error):
                    apiStatusMessage = "Error fetching Sign Language Services: \(error.localizedDescription)"
                }
            }
            
        case "Accessible Hospitals":
            getAccessibleHospitals(lat: region.center.latitude, lon: region.center.longitude, radius: adjustedRadius) { result in
                switch result {
                case .success(let data):
                    let elements = data["elements"] as? [[String: Any]] ?? []
                    handleAPIResults(elements, tag: "Accessible Hospitals")
                    apiStatusMessage = "\(elements.count) Accessible Hospitals found."
                case .failure(let error):
                    apiStatusMessage = "Error fetching Accessible Hospitals: \(error.localizedDescription)"
                }
            }
            
        default:
            break
        }
    }
    



    // Remove markers associated with a particular feature
    private func removeMarkers(for itemName: String) {
        let tag: String
        switch itemName {
        case "Tactile Paving": tag = "Tactile Paving"
        case "Disabled Parking Spaces": tag = "Disabled Parking Spaces"
        case "Wheelchair-accessible Public Toilets": tag = "Wheelchair-accessible Public Toilets"
        case "Ramps": tag = "Ramps"
        case "Elevators/Lifts": tag = "Elevators/Lifts"
        case "Accessible Public Transportation Stops": tag = "Accessible Public Transportation Stops"
        case "Audio Traffic Signals": tag = "Audio Traffic Signals"
        case "Emergency Phones": tag = "Emergency Phones" // New case for Emergency Phones
        case "Accessible Building Entrances": tag = "Accessible Building Entrances" // New case for Accessible Entrances
        case "Hearing Loops": tag = "Hearing Loops" // New case for Hearing Loops
        case "Sign Language Services": tag = "Sign Language Services" // New case for Sign Language Services
        case "Accessible Hospitals": tag = "Accessible Hospitals" // New case for Accessible Hospitals
        default: return
        }
        
        // Filter out any results that match the current tag
        apiResults = apiResults.filter { item in
            item.tag != tag
        }
        
        print("Removed markers for \(tag). Remaining markers: \(apiResults.count)")
    }


    
    
    
    private func getIconName(for tag: String) -> String {
        switch tag {
        case "Tactile Paving":
            return "road.lanes"
        case "Disabled Parking Spaces":
            return "car.fill"
        case "Wheelchair-accessible Public Toilets":
            return "figure.roll"
        case "Ramps":
            return "triangle.fill"
        case "Elevators/Lifts":
            return "arrow.up.arrow.down.circle"
        case "Accessible Public Transportation Stops":
            return "bus"
        case "Audio Traffic Signals":
            return "figure.walk.circle.fill"
        case "Emergency Phones":
            return "phone.fill"
        case "Accessible Building Entrances":
            return "door.left.hand.open"
        case "Hearing Loops":
            return "ear.fill"
        case "Sign Language Services":
            return "hands.sparkles.fill"
        case "Accessible Hospitals":
            return "cross.case.fill"
        default:
            return "mappin"
        }
    }



    
    private func getBackgroundColor(for tag: String) -> Color {
        switch tag {
        case "Tactile Paving":
            return Color.blue
        case "Disabled Parking Spaces":
            return Color.green
        case "Wheelchair-accessible Public Toilets":
            return Color.orange
        case "Ramps":
            return Color.purple
        case "Elevators/Lifts":
            return Color.yellow
        case "Accessible Public Transportation Stops":
            return Color.cyan
        case "Audio Traffic Signals":
            return Color.red
        case "Emergency Phones":
            return Color.pink
        case "Accessible Building Entrances":
            return Color.teal
        case "Hearing Loops":
            return Color.indigo
        case "Sign Language Services":
            return Color.mint
        case "Accessible Hospitals":
            return Color.red.opacity(0.8)
        default:
            return Color.gray
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

    
    
}

class StationConnectionViewModel: ObservableObject {
    @Published var stops: [GTFSStop] = []
    @Published var connections: [StationConnection] = []
    
    // Load both stops and connections from JSON
    func loadConnections() {
        // Load stops from stops.json
        if let stopsURL = Bundle.main.url(forResource: "stops", withExtension: "json") {
            do {
                let stopsData = try Data(contentsOf: stopsURL)
                self.stops = try JSONDecoder().decode([GTFSStop].self, from: stopsData)
            } catch {
                print("Error loading stops: \(error)")
            }
        } else {
            print("stops.json file not found")
        }
        
        // Load connections from station_connections.json
        if let connectionsURL = Bundle.main.url(forResource: "station_connections", withExtension: "json") {
            do {
                let connectionsData = try Data(contentsOf: connectionsURL)
                self.connections = try JSONDecoder().decode([StationConnection].self, from: connectionsData)
            } catch {
                print("Error loading connections: \(error)")
            }
        } else {
            print("station_connections.json file not found")
        }
    }
    
    // Combine stops and connections into one list
    func allMapItems() -> [MapItem] {
        var mapItems: [MapItem] = []
        
        // Add stops as map items
        for stop in stops {
            mapItems.append(MapItem(stop: stop))
        }
        
        // Add connections as map items
        for connection in connections {
            mapItems.append(MapItem(connection: connection))
        }
        
        return mapItems
    }
}


extension Color {
    // Add this custom initializer to convert hex string to Color
    init(hex: String) {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

func getRouteColors(for stop: GTFSStop) -> [String] {
    // Define the route color mapping
    let route_colors: [String: String] = [
        "J Church": "F4D03F",      // Warm Yellow
        "K Ingleside": "5DADE2",   // Soft Blue
        "L Taraval": "AF7AC5",     // Light Purple
        "M Ocean View": "58D68D",  // Fresh Green
        "N Judah": "3498DB",       // Sky Blue
        "T Third Street": "E74C3C" // Soft Red
    ]

    // Split the routes string by commas and trim whitespace
    let routeList = stop.routes.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

    // Fetch the routes and find the corresponding colors
    let routeColors = routeList.compactMap { route in
        return route_colors[String(route)]
    }

    return routeColors
}


struct PDFViewWrapper: UIViewRepresentable {
    let pdfDocument: PDFDocument

    // Create the PDFView
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()

        // Enable interaction features
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        
        pdfView.document = pdfDocument
        return pdfView
    }

    // Update the PDFView
    func updateUIView(_ uiView: PDFView, context: Context) {
        // Handle updates if needed
    }
}



struct ConditionGaugeStyle: GaugeStyle {
    private var greenToRedGradient = LinearGradient(
        gradient: Gradient(colors: [Color.green, Color.yellow, Color.red]),
        startPoint: .leading,
        endPoint: .trailing
    )

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // Background circle (adjust the stroke thickness)
            Circle()
                .foregroundColor(Color(.systemGray6))
                .frame(width: 40, height: 40) // Adjust size of circle

            // Colored trim (stroke thickness adjustable here)
            Circle()
                .trim(from: 0, to: 0.75 * configuration.value)
                .stroke(greenToRedGradient, lineWidth: 8) // Thicker or thinner stroke here
                .rotationEffect(.degrees(135))

            // Dashed outer circle (adjust stroke thickness for outer circle)
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color.black, style: StrokeStyle(lineWidth: 3, lineCap: .butt, lineJoin: .round, dash: [1, 8]))
                .rotationEffect(.degrees(135))

            // Display percentage inside the gauge
            VStack {
                configuration.currentValueLabel
                    .font(.system(size: 17, weight: .bold)) // Even smaller percentage text
                    .foregroundColor(.primary)
            }
        }
    }
}















