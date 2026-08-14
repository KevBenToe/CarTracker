import uuid

from django.conf import settings
from django.db import models

from vehicles.models import Vehicle


class Document(models.Model):
    class DocumentType(models.TextChoices):
        INSURANCE = "insurance", "Insurance"
        REGISTRATION = "registration", "Registration"
        INSPECTION = "inspection", "Inspection"
        MANUAL = "manual", "Manual"
        OTHER = "other", "Other"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    vehicle = models.ForeignKey(
        Vehicle,
        on_delete=models.CASCADE,
        related_name="documents",
    )
    title = models.CharField(max_length=200)
    doc_type = models.CharField(
        max_length=20,
        choices=DocumentType.choices,
        default=DocumentType.OTHER,
    )
    file = models.FileField(upload_to="documents/files/")
    notes = models.TextField(blank=True)
    expiry_date = models.DateField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        related_name="documents",
        blank=True,
        null=True,
    )

    class Meta:
        ordering = ["-created_at"]

    def __str__(self) -> str:
        return self.title
