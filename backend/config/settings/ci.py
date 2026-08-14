"""
CI-specific settings.

Uses the same split from production.py but with DEBUG=True and
no HTTPS redirect so tests can run on the GitHub Actions
PostgreSQL service container provided via DATABASE_URL.
"""

from .production import *  # noqa: F401, F403

DEBUG = True

# Allow all hosts and origins in CI – this is not a public deployment
ALLOWED_HOSTS = ["*"]
CORS_ALLOW_ALL_ORIGINS = True

# CI doesn't sit behind HTTPS, so disable redirect / HSTS
SECURE_SSL_REDIRECT = False
SECURE_HSTS_SECONDS = 0
SESSION_COOKIE_SECURE = False
CSRF_COOKIE_SECURE = False
