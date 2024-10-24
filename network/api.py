import requests
import json

# Function to query the Overpass API and return the results
def query_overpass_api(overpass_query):
    url = "https://overpass-api.de/api/interpreter"
    params = {
        "data": overpass_query
    }
    
    try:
        response = requests.get(url, params=params)
        response.raise_for_status()  # Check if the request was successful
        return response.json()  # Parse JSON response
    except requests.exceptions.HTTPError as err:
        print(f"HTTP error occurred: {err}")
    except Exception as err:
        print(f"An error occurred: {err}")
    return None


def get_tactile_paving(lat, lon, radius):
    query = f"""
    [out:json];
    (
      node["kerb"="lowered"]["tactile_paving"="yes"](around:{radius},{lat},{lon});
      node["highway"="bus_stop"]["tactile_paving"="yes"](around:{radius},{lat},{lon});
      node["highway"="elevator"]["tactile_paving"="yes"](around:{radius},{lat},{lon});
    );
    out body;
    """
    return query_overpass_api(query)


def get_disabled_parking(lat, lon, radius):
    query = f"""
    [out:json];
    node["amenity"="parking"](around:{radius},{lat},{lon});
    out body;
    """
    return query_overpass_api(query)


def get_accessible_toilets(lat, lon, radius):
    query = f"""
    [out:json];
    node["amenity"="toilets"]["wheelchair"="yes"](around:{radius},{lat},{lon});
    out body;
    """
    return query_overpass_api(query)


def get_ramps(lat, lon, radius):
    query = f"""
    [out:json];
    node["ramp"="yes"](around:{radius},{lat},{lon});
    out body;
    """
    return query_overpass_api(query)


def get_elevators(lat, lon, radius):
    query = f"""
    [out:json];
    node["highway"="elevator"](around:{radius},{lat},{lon});
    out body;
    """
    return query_overpass_api(query)


def get_accessible_stops(lat, lon, radius):
    query = f"""
    [out:json];
    node["public_transport"="platform"]["wheelchair"="yes"](around:{radius},{lat},{lon});
    out body;
    """
    return query_overpass_api(query)


def get_audio_traffic_signals(lat, lon, radius):
    query = f"""
    [out:json];
    node["highway"="crossing"]["kerb"="lowered"](around:{radius},{lat},{lon});
    out body;
    """
    return query_overpass_api(query)


def get_emergency_phones(lat, lon, radius):
    query = f"""
    [out:json];
    node["amenity"="emergency_phone"](around:{radius},{lat},{lon});
    out body;
    """
    return query_overpass_api(query)


def get_accessible_entrances(lat, lon, radius):
    query = f"""
    [out:json];
    node["entrance"="main"]["wheelchair"="yes"](around:{radius},{lat},{lon});
    out body;
    """
    return query_overpass_api(query)


def get_hearing_loops(lat, lon, radius):
    query = f"""
    [out:json];
    (
      node["hearing_loop"="yes"](around:{radius},{lat},{lon});
      node["audio_loop"="yes"](around:{radius},{lat},{lon});
    );
    out body;
    """
    return query_overpass_api(query)


def get_sign_language_services(lat, lon, radius):
    query = f"""
    [out:json];
    node["contact:sign_language"="yes"](around:{radius},{lat},{lon});
    out body;
    """
    return query_overpass_api(query)


def get_accessible_hospitals(lat, lon, radius):
    query = f"""
    [out:json];
    node["emergency"="yes"](around:{radius},{lat},{lon});
    out body;
    """
    return query_overpass_api(query)






def collect_data(lat, lon, radius):
    results = {
        "tactile_paving": get_tactile_paving(lat, lon, radius),
        "disabled_parking": get_disabled_parking(lat, lon, radius),
        "accessible_toilets": get_accessible_toilets(lat, lon, radius),
        "ramps": get_ramps(lat, lon, radius),
        "elevators": get_elevators(lat, lon, radius),
        "accessible_stops": get_accessible_stops(lat, lon, radius),
        "audio_traffic_signals": get_audio_traffic_signals(lat, lon, radius),
        "emergency_phones": get_emergency_phones(lat, lon, radius),
        "accessible_entrances": get_accessible_entrances(lat, lon, radius),
        "hearing_loops": get_hearing_loops(lat, lon, radius),
        "sign_language_services": get_sign_language_services(lat, lon, radius),
        "accessible_hospitals": get_accessible_hospitals(lat, lon, radius),
    }
    
    return results

# Example usage
lat, lon = 37.7749, -122.4194  # San Francisco coordinates
radius = 5000  # 5 km radius

# Collect data and save to JSON
data = collect_data(lat, lon, radius)

# Save the collected data to a JSON file
with open("network/accessible_facilities_san_francisco.json", "w") as outfile:
    json.dump(data, outfile, indent=4)

print("Data has been collected and saved to 'accessible_facilities_san_francisco.json'.")