from urllib.parse import parse_qs, unquote, urlparse

from decouple import Csv, config

from .base import *


def database_config_from_url(database_url: str) -> dict:
    parsed = urlparse(database_url)
    query = parse_qs(parsed.query)
    db_config = {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": parsed.path.lstrip("/"),
        "USER": unquote(parsed.username or ""),
        "PASSWORD": unquote(parsed.password or ""),
        "HOST": parsed.hostname or "localhost",
        "PORT": str(parsed.port or "5432"),
    }
    ssl_mode = query.get("sslmode", [None])[0]
    if ssl_mode:
        db_config["OPTIONS"] = {"sslmode": ssl_mode}
    return db_config


DEBUG = False

ALLOWED_HOSTS = config("ALLOWED_HOSTS", cast=Csv(), default="")

CORS_ALLOW_ALL_ORIGINS = False
CORS_ALLOWED_ORIGINS = config("CORS_ALLOWED_ORIGINS", cast=Csv(), default="")

# Security hardening for production
SECURE_SSL_REDIRECT = config("SECURE_SSL_REDIRECT", cast=bool, default=True)
SECURE_HSTS_SECONDS = config("SECURE_HSTS_SECONDS", cast=int, default=31536000)
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True

DATABASES = {
    "default": database_config_from_url(config("DATABASE_URL")),
}
