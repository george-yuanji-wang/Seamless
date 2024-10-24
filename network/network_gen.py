import json
import requests
import igraph as ig
import numpy as np
import matplotlib.pyplot as plt
from scipy.spatial import Delaunay
from geopy.distance import great_circle
from sklearn.manifold import MDS

# Function to calculate Haversine (great-circle) distance between two points
def haversine_distance(coord1, coord2):
    return great_circle(coord1, coord2).kilometers

# Load the JSON data from the previously saved file
with open("network/accessible_facilities_san_francisco.json", "r") as infile:
    data = json.load(infile)

# Prepare a list of coordinates and types for each feature
coordinates = []
feature_types = []

# Extract coordinates and types from the JSON data
for feature, items in data.items():
    if len(items["elements"]) != 0:  # Check if "elements" key exists
        for item in items["elements"]:
            coord = (item["lat"], item["lon"])
            coordinates.append(coord)
            feature_types.append(feature)  # Append the feature type

# Calculate pairwise Haversine distances for all coordinates
num_points = len(coordinates)
dist_matrix = np.zeros((num_points, num_points))

for i in range(num_points):
    for j in range(i + 1, num_points):
        dist = haversine_distance(coordinates[i], coordinates[j])
        dist_matrix[i, j] = dist
        dist_matrix[j, i] = dist  # Since distance is symmetric

# Perform Delaunay triangulation
tri = Delaunay(coordinates)

# Extract edges from Delaunay simplices
edges = set()
for simplex in tri.simplices:
    edges.add((simplex[0], simplex[1]))
    edges.add((simplex[1], simplex[2]))
    edges.add((simplex[2], simplex[0]))

# Create an igraph graph
g = ig.Graph()

# Add vertices with their feature types and lat/lon as attributes
g.add_vertices(num_points)
g.vs["feature_type"] = feature_types  # Assign feature type as an attribute
g.vs["latitude"] = [coord[0] for coord in coordinates]  # Save lat
g.vs["longitude"] = [coord[1] for coord in coordinates]  # Save lon

print("All nodes added")

# Add edges to the graph
g.add_edges(list(edges))

print("All edges added")

# Save the graph with lat/lon information
g.save("network/sanfrancisco_network.graphml")

print("Graph saved as 'sanfrancisco_network.graphml'")