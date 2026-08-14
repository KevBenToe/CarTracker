from rest_framework import viewsets

from .models import Reminder
from .serializers import ReminderSerializer


class ReminderViewSet(viewsets.ModelViewSet):
    serializer_class = ReminderSerializer

    def get_queryset(self):
        queryset = Reminder.objects.select_related("vehicle", "maintenance", "owner")
        vehicle_id = self.request.query_params.get("vehicle")
        if vehicle_id:
            queryset = queryset.filter(vehicle_id=vehicle_id)
        maintenance_id = self.request.query_params.get("maintenance")
        if maintenance_id:
            queryset = queryset.filter(maintenance_id=maintenance_id)
        return queryset
