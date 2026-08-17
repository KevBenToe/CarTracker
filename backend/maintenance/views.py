from django.db.models import Q
from rest_framework import viewsets

from .models import MaintenanceRecord
from .serializers import MaintenanceRecordSerializer

_ALLOWED_MAINTENANCE_STATUSES = {
    MaintenanceRecord.Status.SCHEDULED,
    MaintenanceRecord.Status.COMPLETED,
    MaintenanceRecord.Status.CANCELLED,
}


_ALLOWED_MAINTENANCE_ORDERINGS = {
    "next_due_date",
    "-next_due_date",
    "date",
    "-date",
    "title",
    "-title",
}


class MaintenanceRecordViewSet(viewsets.ModelViewSet):
    serializer_class = MaintenanceRecordSerializer

    def get_queryset(self):
        queryset = MaintenanceRecord.objects.select_related("vehicle", "owner")
        vehicle_id = self.request.query_params.get("vehicle")
        if vehicle_id:
            queryset = queryset.filter(vehicle_id=vehicle_id)
        search = self.request.query_params.get("search", "").strip()
        if search:
            queryset = queryset.filter(
                Q(title__icontains=search) | Q(service_provider__icontains=search)
            )
        status_param = self.request.query_params.get("status", "").strip()
        if status_param and status_param in _ALLOWED_MAINTENANCE_STATUSES:
            queryset = queryset.filter(status=status_param)
        ordering = self.request.query_params.get("ordering", "").strip()
        if ordering in _ALLOWED_MAINTENANCE_ORDERINGS:
            queryset = queryset.order_by(ordering)
        return queryset
