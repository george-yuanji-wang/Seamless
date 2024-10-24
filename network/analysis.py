import json
import igraph as ig
import numpy as np
import matplotlib.pyplot as plt
from geopy.distance import great_circle
from sklearn.manifold import MDS

# Load the graph from the GML file
g = ig.Graph.Read("network/sanfrancisco_network.graphml")

print("graph loaded")

# Define a function to calculate Haversine distance using the graph vertices
def haversine_distance(coord1, coord2):
    return great_circle(coord1, coord2).kilometers

# Extract coordinates from the graph's vertex attributes
coordinates = [(g.vs[i]["latitude"], g.vs[i]["longitude"]) for i in range(g.vcount())]

print("coordinates loaded")
# Use multidimensional scaling (MDS) to generate a 2D layout that preserves distances
mds = MDS(n_components=2, dissimilarity='euclidean', random_state=42)
layout_2d = mds.fit_transform(coordinates)

# Perform Louvain clustering (community detection)
clusters = g.community_multilevel()

print("clustered")

# Function to calculate cluster metrics and feature counts
def calculate_cluster_metrics(cluster_indices):
    # Calculate the centroid of the cluster
    cluster_coords = [coordinates[i] for i in cluster_indices]
    centroid_lat = np.mean([coord[0] for coord in cluster_coords])
    centroid_lon = np.mean([coord[1] for coord in cluster_coords])
    centroid = (centroid_lat, centroid_lon)
    
    # Calculate the radius (max distance from centroid to any point in cluster)
    max_distance = max(haversine_distance(centroid, coord) for coord in cluster_coords)
    
    # Initialize feature counts with all features set to 0
    feature_types = [
        "tactile_paving",
        "disabled_parking",
        "accessible_toilets",
        "ramps",
        "elevators",
        "accessible_stops",
        "audio_traffic_signals",
        "emergency_phones",
        "accessible_entrances",
        "hearing_loops",
        "sign_language_services",
        "accessible_hospitals"
    ]
    
    # Create a dictionary to hold feature counts
    feature_counts = {feature: 0 for feature in feature_types}
    
    # Count the features in the cluster
    for idx in cluster_indices:
        feature_type = g.vs[idx]["feature_type"]
        if feature_type in feature_counts:
            feature_counts[feature_type] += 1

    return centroid, max_distance, feature_counts

# Prepare a dictionary to store the cluster information for JSON output
cluster_data = []

# Topological metrics

for i, cluster in enumerate(clusters):
    # Calculate the centroid, radius, and feature counts of the cluster
    centroid, radius, feature_counts = calculate_cluster_metrics(cluster)
    
    # Subgraph for the current cluster
    subgraph = g.subgraph(cluster)

    # Topological metrics for the cluster
    cluster_diameter = subgraph.diameter()
    avg_path_length = subgraph.average_path_length()
    cluster_density = subgraph.density()
    cluster_clustering_coefficient = subgraph.transitivity_undirected()

    # Replace NaN metrics with 0
    cluster_diameter = cluster_diameter if not np.isnan(cluster_diameter) else 0
    avg_path_length = avg_path_length if not np.isnan(avg_path_length) else 0
    cluster_density = cluster_density if not np.isnan(cluster_density) else 0
    cluster_clustering_coefficient = (
        cluster_clustering_coefficient if not np.isnan(cluster_clustering_coefficient) else 0
    )

    # Store the results in a dictionary for each cluster
    cluster_info = {
        "cluster_id": i + 1,
        "members": cluster,
        "centroid": {"latitude": centroid[0], "longitude": centroid[1]},
        "radius_meters": radius * 1000,  # convert km to meters
        "feature_counts": feature_counts,  # Include the feature counts
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
# with open("network/cluster_data.json", "w") as outfile:
#   json.dump(cluster_data, outfile, indent=4)

# Print the path where JSON is stored
print("Cluster data has been saved to 'network/cluster_data.json'.")

# Generate a color palette for clusters
num_clusters = len(clusters)
palette = plt.get_cmap("tab20")

# Customizing node colors based on clusters
g.vs["color"] = [palette(m % 20) for m in clusters.membership]  # Color nodes by cluster

# Set smaller sizes for vertices and edges
vertex_size = 2  # Smaller vertex size
edge_width = 0.2  # Smaller edge width

# Plot the graph with the customized visual style
fig, ax = plt.subplots()
ig.plot(
    g,
    target=ax,
    layout=layout_2d,
    vertex_size=vertex_size,  # Adjust vertex size 
    vertex_label=None,  # Remove labels for clarity
    edge_color="grey",  # Grey edges
    edge_width=edge_width  # Adjust edge width
)

# Display the plot
plt.show()