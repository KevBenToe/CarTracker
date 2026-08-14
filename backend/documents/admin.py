from django.contrib import admin

from .models import Document


@admin.register(Document)
class DocumentAdmin(admin.ModelAdmin):
    list_display = ("title", "vehicle", "doc_type", "expiry_date", "owner")
    list_filter = ("doc_type", "expiry_date")
    search_fields = ("title", "vehicle__make", "vehicle__model")
