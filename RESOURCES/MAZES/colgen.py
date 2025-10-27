from PIL import Image

# Define tile color constants
BLACK   = (0, 0, 0)
WHITE   = (255, 255, 255)
YELLOW	= (255, 255, 0)
RED     = (255, 0, 0)
BLUE    = (0, 0, 255)
FFAAFF  = (255, 170, 255)
FFAAAA  = (255, 170, 170)

# Classify a tile based on pixel content
def classify_tile(tile_pixels):
    unique_colors = set(tile_pixels)

    if YELLOW in unique_colors:
        return 3  # Super Edible
    if FFAAAA in unique_colors:
        return 2  # Edible
    if RED in unique_colors or BLUE in unique_colors or FFAAFF in unique_colors:
        return 1  # Wall
    if all(color == BLACK for color in unique_colors):
        return 0  # Empty
    return 0  # Default: treat as empty

# Generate collision map from image
def generate_collision_map(image_path):
    img = Image.open(image_path).convert("RGB")
    width, height = img.size

    if width % 6 != 0 or height % 6 != 0:
        raise ValueError("Image dimensions must be divisible by 6.")

    tiles_x = width // 6
    tiles_y = height // 6

    collision_map = []

    for y in range(tiles_y):
        row = []
        for x in range(tiles_x):
            tile = img.crop((x * 6, y * 6, (x + 1) * 6, (y + 1) * 6))
            pixels = list(tile.getdata())
            collision_value = classify_tile(pixels)
            row.append(collision_value)
        collision_map.append(row)  # list of rows

    return collision_map

# Convert and save the collision map with $11 guards
def save_collision_map_bin(collision_rows, filename):
    binary_data = bytearray()

    for row in collision_rows:
        row_bytes = bytearray()
        for i in range(0, len(row), 2):
            nibble1 = row[i]
            nibble2 = row[i+1] if i+1 < len(row) else 0
            byte = (nibble1 << 4) | nibble2
            row_bytes.append(byte)
        
        # Add $11 before and after each row
        binary_data.append(0x11)
        binary_data.extend(row_bytes)
        binary_data.append(0x11)

    with open(filename, "wb") as f:
        f.write(binary_data)

# Print hex collision map
def print_hex_collision_map(collision_rows):
    for row in collision_rows:
        line = ["11"]
        for i in range(0, len(row), 2):
            nibble1 = row[i]
            nibble2 = row[i+1] if i+1 < len(row) else 0
            byte = (nibble1 << 4) | nibble2
            line.append(f"{byte:02X}")
        line.append("11")
        print(" ".join(line))

# Entry point
if __name__ == "__main__":
    import sys
    import os

    if len(sys.argv) != 2:
        print("Usage: python collision_map.py <image.bmp|.png|.jpg>")
        sys.exit(1)

    image_path = sys.argv[1]

    try:
        collision_rows = generate_collision_map(image_path)
        print("Collision Map (Hex, with $11 guards):")
        print_hex_collision_map(collision_rows)

        # Save binary output
        base_name = os.path.splitext(image_path)[0]
        bin_filename = "COL_MAZE.BIN"
        save_collision_map_bin(collision_rows, bin_filename)
        print(f"Binary collision map saved to: {bin_filename}")

    except Exception as e:
        print(f"Error: {e}")

