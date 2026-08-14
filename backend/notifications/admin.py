from django.contrib import admin

from .models import Reminder


@admin.register(Reminder)
class ReminderAdmin(admin.ModelAdmin):
    list_display = ("title", "vehicle", "due_date", "due_mileage", "is_active", "is_sent")
    list_filter = ("is_active", "is_sent", "due_date")
    search_fields = ("title", "message", "vehicle__make", "vehicle__model")
