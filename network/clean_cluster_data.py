import json
import math
from geopy.distance import great_circle
from itertools import combinations
import igraph as ig

# Load the cluster data from the JSON file
with open("network/cluster_data.json", "r") as infile:
    data = json.load(infile)

g = ig.Graph.Read("network/sanfrancisco_network.graphml")

cleaned_data = []

# Function to calculate Haversine distance
def haversine_distance(coord1, coord2):
    return great_circle(coord1, coord2).kilometers

# Function to calculate the mean pairwise distance between all members
def calculate_mean_pairwise_distance(member_coordinates):
    if len(member_coordinates) < 2:
        return 0
    total_distance = 0
    count = 0
    for coord1, coord2 in combinations(member_coordinates, 2):
        total_distance += haversine_distance(coord1, coord2)
        count += 1
    return total_distance / count

# Function to calculate proximity factor (inverted)
def calculate_proximity_factor(member_coordinates):
    mean_distance = calculate_mean_pairwise_distance(member_coordinates)
    return 1 / (1 + mean_distance)

# Function to calculate diversity index based on the feature counts
def calculate_diversity_index(feature_counts):
    total_features = sum(feature_counts.values())
    return len([key for key, value in feature_counts.items() if value > 0]) / total_features if total_features > 0 else 0

# Function to calculate average degree
def calculate_average_degree(g):
    return sum(g.degree()) / g.vcount() if g.vcount() > 0 else 0

# Function to calculate clustering coefficient
def calculate_clustering_coefficient(g):
    return g.transitivity_undirected()

# Function to calculate radius of the cluster
def calculate_radius(centroid, member_coordinates):
    if not member_coordinates:
        return 0
    return max(haversine_distance(centroid, coord) for coord in member_coordinates)

# First pass: Calculate indices and collect them
for i in range(len(data)):
    cluster = {"core_values": {}}
    
    # Check if radius is greater than 10
    if data[i]["radius_meters"] > 10:
        cluster["id"] = data[i]["cluster_id"]
        
        # Round coordinates to 6 decimal places
        cluster["center_coordinate_lat"] = round(data[i]["centroid"]["latitude"], 6)
        cluster["center_coordinate_lon"] = round(data[i]["centroid"]["longitude"], 6)
        
        # Round radius to 2 decimal places
        cluster["radius"] = round(data[i]["radius_meters"], 2)

        # Extract member IDs and their coordinates
        member_ids = data[i]["members"]
        member_coordinates = []
        
        for member_id in member_ids:
            # Assuming `g` is your igraph Graph object that contains the member's coordinates
            latitude = g.vs[member_id]["latitude"]
            longitude = g.vs[member_id]["longitude"]
            member_coordinates.append((latitude, longitude))

        # Calculate proximity factor (inverted)
        proximity_factor = calculate_proximity_factor(member_coordinates)

        # Calculate diversity index
        diversity_index = calculate_diversity_index(data[i]["feature_counts"])

        # Overall accessibility score: sum of proximity (inverted) and diversity
        accessibility_score = proximity_factor + diversity_index
        
        # Store the scores in the cluster
        cluster["accessibility_score"] = round(accessibility_score, 4)
        
        # Calculate topological metrics
        g_subgraph = g.subgraph(member_ids)  # Create subgraph of the cluster
        
        cluster["core_values"].update({
            "average_degree": round(calculate_average_degree(g_subgraph), 2),
            "clustering_coefficient": round(calculate_clustering_coefficient(g_subgraph), 4),
            "radius": round(calculate_radius((cluster["center_coordinate_lat"], cluster["center_coordinate_lon"]), member_coordinates), 2),
        })

        # Store original topology metrics with reduced decimal places
        topology_metrics = data[i]["topology_metrics"]
        cluster["core_values"].update({
            "diameter": round(topology_metrics.get("diameter", 0), 2),
            "average_path_length": round(topology_metrics.get("average_path_length", 0), 2),
            "density": round(topology_metrics.get("density", 0), 4),
            "clustering_coefficient": round(topology_metrics.get("clustering_coefficient", 0), 4),
        })

        # Append cleaned cluster info to the list
        cleaned_data.append(cluster)

# Calculate mean and standard deviation for Z-score normalization
accessibility_scores = [cluster["accessibility_score"] for cluster in cleaned_data]
mean_score = sum(accessibility_scores) / len(accessibility_scores) if accessibility_scores else 0
std_dev = math.sqrt(sum((x - mean_score) ** 2 for x in accessibility_scores) / len(accessibility_scores)) if len(accessibility_scores) > 1 else 0

# First pass: Calculate Z-scores
z_scores = []
for original_score in accessibility_scores:
    if std_dev > 0:
        z_score = (original_score - mean_score) / std_dev
    else:
        z_score = 0  # If all scores are the same
    z_scores.append(z_score)

# Now we need to find the min and max Z-scores
min_z_score = min(z_scores)
max_z_score = max(z_scores)

# Normalize Z-scores to the range [-1, 1]
for cluster, z_score in zip(cleaned_data, z_scores):
    if max_z_score > min_z_score:  # To avoid division by zero
        normalized_score = 2 * ((z_score - min_z_score) / (max_z_score - min_z_score)) - 1
    else:
        normalized_score = 0  # If all Z-scores are the same

    # Round to 4 decimal places
    cluster["accessibility_score"] = round(normalized_score, 4)

# Save cleaned data to a new JSON file
with open("network/cleaned_data.json", "w") as outfile:
    json.dump(cleaned_data, outfile, indent=4)

print("Cleaned data has been saved to 'network/cleaned_data.json'.")
