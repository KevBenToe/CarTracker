from django.db.models import Q
from rest_framework import viewsets

from .models import Vehicle
from .serializers import VehicleSerializer

_ALLOWED_VEHICLE_ORDERINGS = {
    "next_service_date",
    "-next_service_date",
    "license_plate",
    "-license_plate",
    "make",
    "-make",
    "mileage",
    "-mileage",
}


class VehicleViewSet(viewsets.ModelViewSet):
    serializer_class = VehicleSerializer

    def get_queryset(self):
        queryset = Vehicle.objects.all()
        search = self.request.query_params.get("search", "").strip()
        if search:
            queryset = queryset.filter(
                Q(license_plate__icontains=search)
                | Q(vin__icontains=search)
                | Q(make__icontains=search)
                | Q(model__icontains=search)
                | Q(nickname__icontains=search)
            )
        ordering = self.request.query_params.get("ordering", "").strip()
        if ordering in _ALLOWED_VEHICLE_ORDERINGS:
            queryset = queryset.order_by(ordering)
        return queryset
