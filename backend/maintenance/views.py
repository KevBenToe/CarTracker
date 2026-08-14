from rest_framework import viewsets

from .models import MaintenanceRecord
from .serializers import MaintenanceRecordSerializer


class MaintenanceRecordViewSet(viewsets.ModelViewSet):
    serializer_class = MaintenanceRecordSerializer

    def get_queryset(self):
        queryset = MaintenanceRecord.objects.select_related("vehicle", "owner")
        vehicle_id = self.request.query_params.get("vehicle")
        if vehicle_id:
            queryset = queryset.filter(vehicle_id=vehicle_id)
        return queryset
