from celery import shared_task
from PIL import Image
import io

@shared_task
def detect_dominant_color_task(image_bytes):
    image = Image.open(io.BytesIO(image_bytes)).convert('RGB')
    colors = image.getcolors(image.size[0] * image.size[1])
    dominant_color = max(colors, key=lambda tup: tup[0])[1]

    r, g, b = dominant_color

    if r > 200 and g < 100 and b < 100:
        return "Red"
    elif r < 100 and g > 200 and b < 100:
        return "Green"
    elif r < 100 and g < 100 and b > 200:
        return "Blue"
    elif r > 200 and g > 200 and b < 100:
        return "Yellow"
    elif r > 200 and g > 200 and b > 200:
        return "White"
    elif r < 50 and g < 50 and b < 50:
        return "Black"
    else:
        return "Unknown"
