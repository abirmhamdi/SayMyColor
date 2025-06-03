from __future__ import absolute_import, unicode_literals

# Load the Celery application
from .celery import app as celery_app

__all__ = ('celery_app',)
