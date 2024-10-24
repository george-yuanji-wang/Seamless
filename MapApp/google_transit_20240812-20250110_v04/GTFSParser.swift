//
//  GTFSParser.swift
//  MapApp
//
//  Created by George Wang on 10/20/24.
//

import Foundation

struct GTFSStop: Identifiable, Codable {
    var id: String { stop_id } // Use stopId as the unique id

    let stop_id: String
    let stop_name: String
    let latitude: Double
    let longitude: Double
    let routes: String
    let route_color: String
  

}


struct GTFSShapePoint {
    let shapeId: String
    let latitude: Double
    let longitude: Double
    let sequence: Int
}

// GTFS Route model
struct GTFSRoute {
    let routeId: String
    let routeName: String
    let routeColor: String
}

// GTFS Trip model
struct GTFSTrip {
    let tripId: String
    let routeId: String
}

