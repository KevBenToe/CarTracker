from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from django.test import TestCase

from vehicles.models import Vehicle


class VehicleAPITests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.list_url = reverse("vehicle-list")
        self.vehicle_payload = {
            "make": "Toyota",
            "model": "Camry",
            "year": 2022,
            "vin": "1HGCM82633A123456",
            "license_plate": "ABC123",
            "color": "Blue",
            "mileage": 25000,
            "fuel_type": "gasoline",
            "notes": "Primary family car",
        }

    def test_create_vehicle(self):
        response = self.client.post(self.list_url, self.vehicle_payload, format="json")

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Vehicle.objects.count(), 1)
        self.assertEqual(Vehicle.objects.first().make, "Toyota")

    def test_list_vehicles_is_paginated(self):
        Vehicle.objects.create(**self.vehicle_payload)

        response = self.client.get(self.list_url, format="json")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["count"], 1)
        self.assertEqual(len(response.data["results"]), 1)

    def test_retrieve_vehicle(self):
        vehicle = Vehicle.objects.create(**self.vehicle_payload)

        response = self.client.get(reverse("vehicle-detail", args=[vehicle.id]), format="json")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["vin"], self.vehicle_payload["vin"])

    def test_update_vehicle(self):
        vehicle = Vehicle.objects.create(**self.vehicle_payload)

        response = self.client.patch(
            reverse("vehicle-detail", args=[vehicle.id]),
            {"mileage": 30000, "color": "Black"},
            format="json",
        )

        vehicle.refresh_from_db()
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(vehicle.mileage, 30000)
        self.assertEqual(vehicle.color, "Black")

    def test_delete_vehicle(self):
        vehicle = Vehicle.objects.create(**self.vehicle_payload)

        response = self.client.delete(reverse("vehicle-detail", args=[vehicle.id]), format="json")

        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(Vehicle.objects.filter(id=vehicle.id).exists())

    def test_search_vehicles_by_license_plate(self):
        Vehicle.objects.create(**{**self.vehicle_payload, "license_plate": "XYZ999"})
        Vehicle.objects.create(**{**self.vehicle_payload, "license_plate": "ABC123", "vin": "1HGCM82633A000001"})

        response = self.client.get(f"{self.list_url}?search=XYZ999", format="json")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["count"], 1)
        self.assertEqual(response.data["results"][0]["license_plate"], "XYZ999")

    def test_search_vehicles_by_vin(self):
        Vehicle.objects.create(**{**self.vehicle_payload, "vin": "UNIQUEVIN00000001"})
        Vehicle.objects.create(**{**self.vehicle_payload, "vin": "OTHERVIN00000001", "license_plate": "DEF456"})

        response = self.client.get(f"{self.list_url}?search=UNIQUEVIN", format="json")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["count"], 1)
        self.assertEqual(response.data["results"][0]["vin"], "UNIQUEVIN00000001")

    def test_search_vehicles_by_make(self):
        Vehicle.objects.create(**self.vehicle_payload)
        Vehicle.objects.create(**{**self.vehicle_payload, "make": "Honda", "license_plate": "DEF456", "vin": "1HGCM82633A000002"})

        response = self.client.get(f"{self.list_url}?search=Honda", format="json")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["count"], 1)
        self.assertEqual(response.data["results"][0]["make"], "Honda")

    def test_order_vehicles_by_license_plate(self):
        Vehicle.objects.create(**{**self.vehicle_payload, "license_plate": "ZZZ000", "vin": "1HGCM82633A000003"})
        Vehicle.objects.create(**{**self.vehicle_payload, "license_plate": "AAA111", "vin": "1HGCM82633A000004"})

        response = self.client.get(f"{self.list_url}?ordering=license_plate", format="json")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        plates = [v["license_plate"] for v in response.data["results"]]
        self.assertEqual(plates, sorted(plates))
