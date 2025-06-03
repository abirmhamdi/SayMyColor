from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework import generics
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import get_user_model
from rest_framework import generics, permissions
from .models import DeviceSession
from .serializers import DeviceSessionSerializer



from .serializers import (
    RegisterSerializer,
    LoginSerializer,
    UserSerializer,
    ResetPasswordSerializer
)
User = get_user_model()

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [AllowAny]

class LoginView(generics.GenericAPIView):
    serializer_class = LoginSerializer

    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')

        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({'detail': 'Email ou mot de passe invalide.'}, status=401)

        if not user.check_password(password):
            return Response({'detail': 'Email ou mot de passe invalide.'}, status=401)

        refresh = RefreshToken.for_user(user)
        return Response({
            'refresh': str(refresh),
            'access': str(refresh.access_token),
            'user': UserSerializer(user).data
        })
    
class DashboadView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        return Response({
            'message': 'Bienvenue sur votre dashboard',
            'user': UserSerializer(user).data
        })

class ResetPasswordView(generics.GenericAPIView):
    serializer_class = ResetPasswordSerializer
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({"detail": "Mot de passe réinitialisé avec succès."})
        return Response(serializer.errors, status=400)
    
class DeviceSessionCreateView(generics.CreateAPIView):
    serializer_class = DeviceSessionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class DeviceSessionListView(generics.ListAPIView):
    serializer_class = DeviceSessionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return DeviceSession.objects.filter(user=self.request.user)
    
class MyDeviceSessionsView(generics.ListAPIView):
    serializer_class = DeviceSessionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return DeviceSession.objects.filter(user=self.request.user)
    
    
from rest_framework.parsers import MultiPartParser, FormParser
from .tasks import detect_dominant_color_task

class ColorDetectionView(APIView):
    permission_classes = [AllowAny]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request, format=None):
        if 'image' not in request.FILES:
            return Response({'error': 'No image provided'}, status=400)

        image_file = request.FILES['image']
        image_bytes = image_file.read()

        result = detect_dominant_color_task(image_bytes)  # If you want async, use `.delay()`
        return Response({'color': result})
