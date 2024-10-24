//
//  API.swift
//  MapApp
//
//  Created by George Wang on 10/20/24.
//


import Foundation

// Function to make Overpass API request
func queryOverpassAPI(overpassQuery: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    let url = "https://overpass-api.de/api/interpreter"
    var urlComponents = URLComponents(string: url)!
    urlComponents.queryItems = [URLQueryItem(name: "data", value: overpassQuery)]
    
    guard let finalURL = urlComponents.url else {
        return completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
    }
    
    let task = URLSession.shared.dataTask(with: finalURL) { (data, response, error) in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            return completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                completion(.success(json))
            } else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"])))
            }
        } catch {
            completion(.failure(error))
        }
    }
    task.resume()
}

// MARK: - Functions for each feature

// 1. Tactile Paving
func getTactilePaving(lat: Double, lon: Double, radius: Double, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    let query = """
    [out:json];
    (
      node["kerb"="lowered"]["tactile_paving"="yes"](around:\(radius),\(lat),\(lon));
      node["highway"="bus_stop"]["tactile_paving"="yes"](around:\(radius),\(lat),\(lon));
      node["highway"="elevator"]["tactile_paving"="yes"](around:\(radius),\(lat),\(lon));
    );
    out body;
    """
    queryOverpassAPI(overpassQuery: query, completion: completion)
}

// 2. Disabled Parking Spaces
func getDisabledParking(lat: Double, lon: Double, radius: Double, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    let query = """
    [out:json];
    node["amenity"="parking"](around:\(radius),\(lat),\(lon));
    out body;
    """
    
    /*"""
    [out:json];
    node["amenity"="parking"]["parking"="disabled"](around:\(radius),\(lat),\(lon));
    out body;
    """*/
    queryOverpassAPI(overpassQuery: query, completion: completion)
}

// 3. Wheelchair-accessible public toilets
func getAccessibleToilets(lat: Double, lon: Double, radius: Double, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    let query = """
    [out:json];
    node["amenity"="toilets"]["wheelchair"="yes"](around:\(radius),\(lat),\(lon));
    out body;
    """
    queryOverpassAPI(overpassQuery: query, completion: completion)
}

// 4. Ramps
func getRamps(lat: Double, lon: Double, radius: Double, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    let query = """
    [out:json];
    node[["ramp"="yes"]](around:\(radius),\(lat),\(lon));
    out body;
    """
    queryOverpassAPI(overpassQuery: query, completion: completion)
}

// 5. Elevators/Lifts
func getElevators(lat: Double, lon: Double, radius: Double, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    let query = """
    [out:json];
    node["highway"="elevator"](around:\(radius),\(lat),\(lon));
    out body;
    """
    queryOverpassAPI(overpassQuery: query, completion: completion)
}

// 6. Accessible Public Transportation Stops
func getAccessibleStops(lat: Double, lon: Double, radius: Double, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    let query = """
    [out:json];
    node["public_transport"="platform"]["wheelchair"="yes"](around:\(radius),\(lat),\(lon));
    out body;
    """
    queryOverpassAPI(overpassQuery: query, completion: completion)
}

// 7. Audio Traffic Signals
func getAudioTrafficSignals(lat: Double, lon: Double, radius: Double, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    let query = """
    [out:json];
    node["highway"="crossing"]
        ["kerb"="lowered"]
        (around:\(radius),\(lat),\(lon));
    out body;
    """
    queryOverpassAPI(overpassQuery: query, completion: completion)
}

// 8. Emergency Phones
func getEmergencyPhones(lat: Double, lon: Double, radius: Double, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    let query = """
    [out:json];
    node["amenity"="emergency_phone"](around:\(radius),\(lat),\(lon));
    out body;
    """
    queryOverpassAPI(overpassQuery: query, completion: completion)
}

// 9. Accessible Building Entrances
func getAccessibleEntrances(lat: Double, lon: Double, radius: Double, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    let query = """
    [out:json];
    node["entrance"="main"]["wheelchair"="yes"](around:\(radius),\(lat),\(lon));
    out body;
    """
    queryOverpassAPI(overpassQuery: query, completion: completion)
}

// 10. Hearing Loops
func getHearingLoops(lat: Double, lon: Double, radius: Double, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    let query = """
    [out:json];
    (
      node["hearing_loop"="yes"](around:\(radius),\(lat),\(lon));
      node["audio_loop"="yes"](around:\(radius),\(lat),\(lon));
    );
    out body;
    """
    queryOverpassAPI(overpassQuery: query, completion: completion)
}

// 11. Sign Language Services
func getSignLanguageServices(lat: Double, lon: Double, radius: Double, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    let query = """
    [out:json];
    node["contact:sign_language"="yes"](around:\(radius),\(lat),\(lon));
    out body;
    """
    queryOverpassAPI(overpassQuery: query, completion: completion)
}


// 12. Accessible Hospitals
func getAccessibleHospitals(lat: Double, lon: Double, radius: Double, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    let query = """
    [out:json];
    node["emergency"="yes"](around:\(radius),\(lat),\(lon));
    out body;
    """
    queryOverpassAPI(overpassQuery: query, completion: completion)
}

