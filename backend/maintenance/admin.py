from django.contrib import admin

from .models import MaintenanceRecord


@admin.register(MaintenanceRecord)
class MaintenanceRecordAdmin(admin.ModelAdmin):
    list_display = ("title", "vehicle", "date", "status", "cost", "owner")
    list_filter = ("status", "date")
    search_fields = ("title", "vehicle__make", "vehicle__model", "service_provider")
