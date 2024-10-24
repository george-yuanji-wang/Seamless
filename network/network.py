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

# Add vertices with their feature types as attributes
g.add_vertices(num_points)
g.vs["feature_type"] = feature_types  # Assign feature type as an attribute

# Add edges to the graph
g.add_edges(list(edges))

# Use multidimensional scaling (MDS) to generate a 2D layout that preserves distances
mds = MDS(n_components=2, dissimilarity='precomputed', random_state=42)
layout_2d = mds.fit_transform(dist_matrix)

# Perform Louvain clustering (community detection)
clusters = g.community_multilevel()

# Function to calculate cluster metrics
def calculate_cluster_metrics(cluster_indices):
    # Calculate the centroid of the cluster
    cluster_coords = [coordinates[i] for i in cluster_indices]
    centroid_lat = np.mean([coord[0] for coord in cluster_coords])
    centroid_lon = np.mean([coord[1] for coord in cluster_coords])
    centroid = (centroid_lat, centroid_lon)
    
    # Calculate the radius (max distance from centroid to any point in cluster)
    max_distance = max(haversine_distance(centroid, coord) for coord in cluster_coords)
    
    return centroid, max_distance

# Prepare a dictionary to store the cluster information for JSON output
cluster_data = []

# Topological metrics
for i, cluster in enumerate(clusters):
    # Calculate the centroid and radius of the cluster
    centroid, radius = calculate_cluster_metrics(cluster)
    
    # Subgraph for the current cluster
    subgraph = g.subgraph(cluster)
    
    # Topological metrics for the cluster
    cluster_diameter = subgraph.diameter()
    avg_path_length = subgraph.average_path_length()
    cluster_density = subgraph.density()
    cluster_clustering_coefficient = subgraph.transitivity_undirected()

    # Store the results in a dictionary for each cluster
    cluster_info = {
        "cluster_id": i + 1,
        "members": cluster,
        "centroid": {"latitude": centroid[0], "longitude": centroid[1]},
        "radius_meters": radius * 1000,  # convert km to meters
        "topology_metrics": {
            "diameter": cluster_diameter,
            "average_path_length": avg_path_length,
            "density": cluster_density,
            "clustering_coefficient": cluster_clustering_coefficient
        }
    }
    
    # Append cluster info to the cluster_data list
    cluster_data.append(cluster_info)

# Store the data in a JSON file
with open("cluster_data.json", "w") as outfile:
    json.dump(cluster_data, outfile, indent=4)

# Print the path where JSON is stored
print("Cluster data has been saved to 'cluster_data.json'.")

# Generate a color palette for clusters
num_clusters = len(clusters)
palette = plt.get_cmap("tab20")

# Customizing node colors based on clusters
g.vs["color"] = [palette(m % 20) for m in clusters.membership]  # Color nodes by cluster

# Plot the graph with the customized visual style
fig, ax = plt.subplots()
ig.plot(
    g,
    target=ax,
    layout=layout_2d,
    vertex_size=25,
    vertex_label=None,  # Remove labels for clarity
    edge_color="grey"   # Grey edges
)

# Display the plot
plt.show()
