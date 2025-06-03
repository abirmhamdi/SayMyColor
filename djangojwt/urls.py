from django.contrib import admin
from django.urls import path
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)
from myapp.views import (
    RegisterView, LoginView, DashboadView, ResetPasswordView,
    DeviceSessionCreateView, DeviceSessionListView, MyDeviceSessionsView,
    ColorDetectionView
)
from graphene_django.views import GraphQLView
from django.views.decorators.csrf import csrf_exempt

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth/register/', RegisterView.as_view(), name="auth_register"),
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/auth/login/', LoginView.as_view(), name="auth_login"),
    path('api/dashboard/', DashboadView.as_view(), name="dashboard"),
    path('api/auth/reset-password/', ResetPasswordView.as_view(), name='reset_password'),
    path('api/devices/create/', DeviceSessionCreateView.as_view(), name='create_device'),
    path('api/devices/mine/', DeviceSessionListView.as_view(), name='my_devices'),
    path('devices/mine/', MyDeviceSessionsView.as_view(), name='my-device-sessions'),
    path("graphql/", csrf_exempt(GraphQLView.as_view(graphiql=True))),
    path('api/color/', ColorDetectionView.as_view(), name='color-detection'),
]
