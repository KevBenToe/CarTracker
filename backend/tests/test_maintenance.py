from django.test import TestCase
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from maintenance.models import MaintenanceRecord
from vehicles.models import Vehicle


class MaintenanceRecordAPITests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.vehicle = Vehicle.objects.create(
            make="Honda",
            model="Civic",
            year=2021,
            mileage=12000,
            fuel_type="gasoline",
        )
        self.list_url = reverse("maintenance-record-list")

    def test_create_maintenance_record(self):
        payload = {
            "vehicle": str(self.vehicle.id),
            "title": "Oil Change",
            "description": "Synthetic oil service",
            "date": "2026-08-01",
            "mileage_at_service": 12000,
            "cost": "79.99",
            "service_provider": "Local Garage",
            "status": "completed",
            "next_due_date": "2027-02-01",
            "next_due_mileage": 18000,
        }

        response = self.client.post(self.list_url, payload, format="json")

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(MaintenanceRecord.objects.count(), 1)

    def test_filter_maintenance_by_vehicle(self):
        other_vehicle = Vehicle.objects.create(
            make="Ford",
            model="Focus",
            year=2020,
            mileage=30000,
            fuel_type="gasoline",
        )
        MaintenanceRecord.objects.create(
            vehicle=self.vehicle,
            title="Tire Rotation",
            date="2026-08-01",
            status="completed",
        )
        MaintenanceRecord.objects.create(
            vehicle=other_vehicle,
            title="Brake Service",
            date="2026-08-02",
            status="scheduled",
        )

        response = self.client.get(f"{self.list_url}?vehicle={self.vehicle.id}", format="json")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["count"], 1)
        self.assertEqual(response.data["results"][0]["title"], "Tire Rotation")

    def test_search_maintenance_by_title(self):
        MaintenanceRecord.objects.create(
            vehicle=self.vehicle, title="Oil Change", date="2026-08-01", status="completed"
        )
        MaintenanceRecord.objects.create(
            vehicle=self.vehicle, title="Brake Service", date="2026-08-02", status="scheduled"
        )

        response = self.client.get(f"{self.list_url}?search=Oil", format="json")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["count"], 1)
        self.assertEqual(response.data["results"][0]["title"], "Oil Change")

    def test_filter_maintenance_by_status(self):
        MaintenanceRecord.objects.create(
            vehicle=self.vehicle, title="Oil Change", date="2026-08-01", status="completed"
        )
        MaintenanceRecord.objects.create(
            vehicle=self.vehicle, title="Brake Service", date="2026-08-02", status="scheduled"
        )

        response = self.client.get(f"{self.list_url}?status=scheduled", format="json")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["count"], 1)
        self.assertEqual(response.data["results"][0]["title"], "Brake Service")

    def test_order_maintenance_by_next_due_date(self):
        MaintenanceRecord.objects.create(
            vehicle=self.vehicle, title="First", date="2026-08-01",
            status="completed", next_due_date="2027-06-01"
        )
        MaintenanceRecord.objects.create(
            vehicle=self.vehicle, title="Second", date="2026-08-02",
            status="scheduled", next_due_date="2027-01-01"
        )

        response = self.client.get(f"{self.list_url}?ordering=next_due_date", format="json")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        titles = [r["title"] for r in response.data["results"]]
        self.assertEqual(titles[0], "Second")
        self.assertEqual(titles[1], "First")
