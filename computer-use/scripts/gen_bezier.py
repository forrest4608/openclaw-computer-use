#!/usr/bin/env python3
import sys
import random
import math

def bezier_point(t, p0, p1, p2, p3):
    """Calculate point on cubic Bezier curve at t (0 to 1)."""
    return (
        (1-t)**3 * p0 + 
        3 * (1-t)**2 * t * p1 + 
        3 * (1-t) * t**2 * p2 + 
        t**3 * p3
    )

def generate_human_path(start_x, start_y, end_x, end_y, steps=20):
    """Generate a human-like mouse path using Bezier curves with randomness."""
    
    # Random control points to simulate natural arc
    # Control point 1: offset from start
    ctrl1_x = start_x + random.randint(-100, 100)
    ctrl1_y = start_y + random.randint(-100, 100)
    
    # Control point 2: offset from end
    ctrl2_x = end_x + random.randint(-100, 100)
    ctrl2_y = end_y + random.randint(-100, 100)
    
    path = []
    
    # Generate points along the curve
    for i in range(steps + 1):
        t = i / steps
        # Apply easing function (ease-in-out) for speed variation
        # t_eased = t * t * (3 - 2 * t)  # SmoothStep
        # Or just linear t is fine if we vary wait times; let's use t for simplicity of points
        
        x = bezier_point(t, start_x, ctrl1_x, ctrl2_x, end_x)
        y = bezier_point(t, start_y, ctrl1_y, ctrl2_y, end_y)
        
        # Add micro-jitter (tremor)
        if 0 < i < steps:
            x += random.randint(-2, 2)
            y += random.randint(-2, 2)
            
        path.append((int(x), int(y)))
        
    return path

def main():
    if len(sys.argv) != 5:
        print("Usage: python3 gen_bezier.py <start_x> <start_y> <end_x> <end_y>", file=sys.stderr)
        sys.exit(1)
        
    try:
        sx, sy = int(sys.argv[1]), int(sys.argv[2])
        ex, ey = int(sys.argv[3]), int(sys.argv[4])
    except ValueError:
        print("Coordinates must be integers", file=sys.stderr)
        sys.exit(1)
        
    # Calculate distance to determine number of steps
    distance = math.sqrt((ex - sx)**2 + (ey - sy)**2)
    
    # Adjust steps based on distance (more steps for longer moves)
    # Minimum 5 steps, max 50. E.g., 1 step per 15-30 pixels
    steps = max(5, min(50, int(distance / 20)))
    
    # If very close, just jump
    if distance < 10:
        print(f"m:{ex},{ey}")
        return

    path = generate_human_path(sx, sy, ex, ey, steps)
    
    # Format for cliclick: m:x,y w:wait_ms m:x,y ...
    cmds = []
    for x, y in path:
        cmds.append(f"m:{x},{y}")
        # Random wait between defined points simulates human speed variation
        # Faster in middle (less wait), slower at ends?
        # For simplicity, just small random wait
        cmds.append(f"w:{random.randint(1, 5)}") 
        
    # Print as space-separated string for cliclick
    print(" ".join(cmds))

if __name__ == "__main__":
    main()
