import uuid

from django.conf import settings
from django.db import models

from maintenance.models import MaintenanceRecord
from vehicles.models import Vehicle


class Reminder(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    vehicle = models.ForeignKey(
        Vehicle,
        on_delete=models.CASCADE,
        related_name="reminders",
    )
    maintenance = models.ForeignKey(
        MaintenanceRecord,
        on_delete=models.SET_NULL,
        related_name="reminders",
        blank=True,
        null=True,
    )
    title = models.CharField(max_length=200)
    message = models.TextField()
    due_date = models.DateField(blank=True, null=True)
    due_mileage = models.PositiveIntegerField(blank=True, null=True)
    is_active = models.BooleanField(default=True)
    is_sent = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        related_name="reminders",
        blank=True,
        null=True,
    )

    class Meta:
        ordering = ["is_sent", "due_date", "-created_at"]

    def __str__(self) -> str:
        return self.title
