import shutil
from pathlib import Path

from django.conf import settings
from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import TestCase, override_settings
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from documents.models import Document
from vehicles.models import Vehicle


TEST_MEDIA_ROOT = Path(settings.BASE_DIR) / "test_media"


@override_settings(MEDIA_ROOT=TEST_MEDIA_ROOT)
class DocumentAPITests(TestCase):
    @classmethod
    def tearDownClass(cls):
        super().tearDownClass()
        if TEST_MEDIA_ROOT.exists():
            shutil.rmtree(TEST_MEDIA_ROOT)

    def setUp(self):
        self.client = APIClient()
        self.vehicle = Vehicle.objects.create(
            make="Tesla",
            model="Model 3",
            year=2023,
            mileage=5000,
            fuel_type="electric",
        )
        self.list_url = reverse("document-list")

    def test_create_document(self):
        upload = SimpleUploadedFile(
            "registration.pdf",
            b"fake pdf content",
            content_type="application/pdf",
        )
        payload = {
            "vehicle": str(self.vehicle.id),
            "title": "Registration",
            "doc_type": "registration",
            "file": upload,
            "notes": "Current year registration",
            "expiry_date": "2027-01-31",
        }

        response = self.client.post(self.list_url, payload, format="multipart")

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Document.objects.count(), 1)

    def test_filter_documents_by_vehicle(self):
        other_vehicle = Vehicle.objects.create(
            make="Mazda",
            model="CX-5",
            year=2022,
            mileage=18000,
            fuel_type="gasoline",
        )
        Document.objects.create(
            vehicle=self.vehicle,
            title="Insurance Policy",
            doc_type="insurance",
            file=SimpleUploadedFile("insurance.txt", b"policy", content_type="text/plain"),
        )
        Document.objects.create(
            vehicle=other_vehicle,
            title="Manual",
            doc_type="manual",
            file=SimpleUploadedFile("manual.txt", b"manual", content_type="text/plain"),
        )

        response = self.client.get(f"{self.list_url}?vehicle={self.vehicle.id}", format="json")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["count"], 1)
        self.assertEqual(response.data["results"][0]["title"], "Insurance Policy")
