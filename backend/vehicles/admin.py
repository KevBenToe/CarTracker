from django.contrib import admin

from .models import Vehicle


@admin.register(Vehicle)
class VehicleAdmin(admin.ModelAdmin):
    list_display = ("make", "model", "year", "license_plate", "mileage", "owner")
    list_filter = ("fuel_type", "year")
    search_fields = ("make", "model", "vin", "license_plate")
