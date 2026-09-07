import os
import urllib.request
from concurrent.futures import ThreadPoolExecutor

BASE_URL = 'https://cdn.jsdelivr.net/gh/googlefonts/noto-emoji@main/png/512/'

ITEMS = {
    # Shapes
    'assets/images/shapes/circle.png': 'emoji_u1f534.png',
    'assets/images/shapes/square.png': 'emoji_u1f7e5.png',
    'assets/images/shapes/triangle.png': 'emoji_u1f53a.png',
    'assets/images/shapes/star.png': 'emoji_u2b50.png',
    'assets/images/shapes/heart.png': 'emoji_u2764.png',
    'assets/images/shapes/diamond.png': 'emoji_u1f537.png',
    'assets/images/shapes/crescent.png': 'emoji_u1f319.png',
    'assets/images/shapes/cross.png': 'emoji_u2795.png',
    'assets/images/shapes/hexagon.png': 'emoji_u2b21.png',
    'assets/images/shapes/rectangle.png': 'emoji_u1f7e6.png',
    'assets/images/shapes/oval.png': 'emoji_u2b55.png',
    
    # Colors
    'assets/images/colors/red.png': 'emoji_u1f534.png',
    'assets/images/colors/blue.png': 'emoji_u1f535.png',
    'assets/images/colors/green.png': 'emoji_u1f7e2.png',
    'assets/images/colors/yellow.png': 'emoji_u1f7e1.png',
    'assets/images/colors/orange.png': 'emoji_u1f7e0.png',
    'assets/images/colors/purple.png': 'emoji_u1f7e3.png',
    'assets/images/colors/brown.png': 'emoji_u1f7e4.png',
    'assets/images/colors/black.png': 'emoji_u26ab.png',
    'assets/images/colors/white.png': 'emoji_u26aa.png',
    'assets/images/colors/pink.png': 'emoji_u1f497.png',
    
    # Vehicles
    'assets/images/vehicles/bus.png': 'emoji_u1f68c.png',
    'assets/images/vehicles/taxi.png': 'emoji_u1f695.png',
    'assets/images/vehicles/airplane.png': 'emoji_u2708.png',
    'assets/images/vehicles/helicopter.png': 'emoji_u1f681.png',
    'assets/images/vehicles/ship.png': 'emoji_u1f6a2.png',
    'assets/images/vehicles/fire_truck.png': 'emoji_u1f692.png',
    'assets/images/vehicles/tractor.png': 'emoji_u1f69c.png',
    'assets/images/vehicles/scooter.png': 'emoji_u1f6f5.png',
    
    # Animals
    'assets/images/animals/cow.png': 'emoji_u1f42e.png',
    'assets/images/animals/pig.png': 'emoji_u1f437.png',
    'assets/images/animals/penguin.png': 'emoji_u1f427.png',
    'assets/images/animals/fox.png': 'emoji_u1f98a.png',
    'assets/images/animals/butterfly.png': 'emoji_u1f98b.png',
    'assets/images/animals/duck.png': 'emoji_u1f986.png',
    'assets/images/animals/monkey.png': 'emoji_u1f412.png',
    'assets/images/animals/rabbit.png': 'emoji_u1f430.png',
    
    # Fruits
    'assets/images/fruits/banana.png': 'emoji_u1f34c.png',
    'assets/images/fruits/strawberry.png': 'emoji_u1f353.png',
    'assets/images/fruits/pineapple.png': 'emoji_u1f34d.png',
    'assets/images/fruits/cherry.png': 'emoji_u1f352.png',
    'assets/images/fruits/peach.png': 'emoji_u1f351.png',
    'assets/images/fruits/lemon.png': 'emoji_u1f34b.png',
}

def download_item(item):
    dest, filename = item
    if os.path.exists(dest) and os.path.getsize(dest) > 1000:
        return True
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    url = BASE_URL + filename
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=25) as resp, open(dest, 'wb') as f:
            f.write(resp.read())
        print(f"Downloaded: {dest}", flush=True)
        return True
    except Exception as e:
        print(f"Failed {dest} ({filename}): {e}", flush=True)
        return False

def main():
    items = list(ITEMS.items())
    with ThreadPoolExecutor(max_workers=8) as ex:
        results = list(ex.map(download_item, items))
    print(f"Complete: {sum(results)}/{len(items)} ready.", flush=True)

if __name__ == '__main__':
    main()
