from django.db import models
from django.contrib.auth.models import AbstractUser

from django.conf import settings
from django.utils import timezone


class AppUser(AbstractUser):
    email = models.EmailField(unique=True)

    USERNAME_FIELD = 'email'             
    REQUIRED_FIELDS = ['username']        

    def __str__(self):
        return self.email


class DeviceSession(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='sessions')
    device_name = models.CharField(max_length=100)
    device_type = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=['user', 'device_name'], name='unique_user_device')
        ]

    def is_expired(self):
        return timezone.now() > self.expires_at

    def __str__(self):
        return f"{self.user.email} - {self.device_name}"
