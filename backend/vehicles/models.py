import uuid
from datetime import date

from django.conf import settings
from django.core.exceptions import ValidationError
from django.core.validators import MinValueValidator
from django.db import models


def validate_vehicle_year(value: int) -> None:
    current_max_year = date.today().year + 1
    if value > current_max_year:
        raise ValidationError(f"Year must be {current_max_year} or earlier.")


class Vehicle(models.Model):
    class FuelType(models.TextChoices):
        GASOLINE = "gasoline", "Gasoline"
        DIESEL = "diesel", "Diesel"
        ELECTRIC = "electric", "Electric"
        HYBRID = "hybrid", "Hybrid"
        PLUGIN_HYBRID = "plugin_hybrid", "Plugin Hybrid"
        OTHER = "other", "Other"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    make = models.CharField(max_length=100)
    model = models.CharField(max_length=100)
    year = models.PositiveIntegerField(
        validators=[
            MinValueValidator(1886),
            validate_vehicle_year,
        ]
    )
    vin = models.CharField(max_length=17, blank=True)
    license_plate = models.CharField(max_length=32, blank=True)
    color = models.CharField(max_length=50, blank=True)
    mileage = models.PositiveIntegerField(default=0)
    fuel_type = models.CharField(
        max_length=20,
        choices=FuelType.choices,
        default=FuelType.GASOLINE,
    )
    notes = models.TextField(blank=True)
    image = models.ImageField(upload_to="vehicles/images/", blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        related_name="vehicles",
        blank=True,
        null=True,
    )

    class Meta:
        ordering = ["-created_at", "make", "model"]

    def __str__(self) -> str:
        return f"{self.year} {self.make} {self.model}".strip()
