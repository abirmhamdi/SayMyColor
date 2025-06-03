from __future__ import absolute_import, unicode_literals
import os
from celery import Celery

# Set default Django settings
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'djangojwt.settings')

# Create Celery app with Redis as the broker
app = Celery('djangojwt', broker='redis://localhost:6379/0')

# Load task-related settings
app.config_from_object('django.conf:settings', namespace='CELERY')

# Auto-discover tasks from all registered Django app configs
app.autodiscover_tasks()

# Optional debug task
@app.task(bind=True)
def debug_task(self):
    print(f'Request: {self.request!r}')
