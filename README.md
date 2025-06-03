--- SayMyColor ---
SayMyColor is a Flutter application built to help individuals with visual impairments or color blindness identify colors. 
By using AI-powered image recognition and real-time text-to-speech, the app announces the detected color of any image the user selects or captures.

--- Features ---
Select an image from the gallery
Detect the main color using an AI-powered backend
Announce the color using text-to-speech (TTS)
Clean, accessible user interface
Navigation support (including a back button to the login screen)

--- Technologies Used ---
//Frontend:
Flutter (Dart)
image_picker – to pick images from the gallery
flutter_tts – to convert detected color text into speech
http – to communicate with the backend API
flutter_animate – for UI animations
//Backend:
Django + Django REST Framework (not included in this repository)
Celery for background image processing

