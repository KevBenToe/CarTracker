from rest_framework import serializers

from .models import Vehicle


class VehicleSerializer(serializers.ModelSerializer):
    image = serializers.ImageField(
        use_url=True,
        required=False,
        allow_null=True,
    )

    class Meta:
        model = Vehicle
        fields = "__all__"
        read_only_fields = ("id", "created_at", "updated_at")

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        request = self.context.get("request")
        if representation.get("image") and request is not None:
            representation["image"] = request.build_absolute_uri(
                representation["image"]
            )
        return representation
