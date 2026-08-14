from rest_framework import viewsets

from .models import Document
from .serializers import DocumentSerializer


class DocumentViewSet(viewsets.ModelViewSet):
    serializer_class = DocumentSerializer

    def get_queryset(self):
        queryset = Document.objects.select_related("vehicle", "owner")
        vehicle_id = self.request.query_params.get("vehicle")
        if vehicle_id:
            queryset = queryset.filter(vehicle_id=vehicle_id)
        return queryset
