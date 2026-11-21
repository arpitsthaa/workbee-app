from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import User


class StudentRegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = ["id", "full_name", "email", "password", "college_university"]

    def validate_full_name(self, value):
        if not value or not value.strip():
            raise serializers.ValidationError("Full name is required.")
        return value.strip()

    def validate_college_university(self, value):
        if not value or not value.strip():
            raise serializers.ValidationError("College or university is required.")
        return value.strip()

    def create(self, validated_data):
        return User.objects.create_user(
            email=validated_data["email"],
            password=validated_data["password"],
            role="student",
            full_name=validated_data["full_name"],
            college_university=validated_data["college_university"],
        )


class BusinessRegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)
    confirm_password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = [
            "id",
            "business_name",
            "contact_person",
            "email",
            "phone",
            "location",
            "pan_number",
            "password",
            "confirm_password",
        ]

    def validate_pan_number(self, value):
        if not value or not value.isdigit() or len(value) != 9:
            raise serializers.ValidationError("PAN number must be exactly 9 digits.")
        return value

    def validate(self, attrs):
        if attrs["password"] != attrs["confirm_password"]:
            raise serializers.ValidationError({"confirm_password": "Passwords do not match."})
        return attrs

    def create(self, validated_data):
        validated_data.pop("confirm_password")
        return User.objects.create_user(
            email=validated_data["email"],
            password=validated_data["password"],
            role="business",
            business_name=validated_data["business_name"],
            contact_person=validated_data["contact_person"],
            phone=validated_data["phone"],
            location=validated_data["location"],
            pan_number=validated_data["pan_number"],
        )


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        user = authenticate(email=attrs["email"], password=attrs["password"])
        if not user:
            raise serializers.ValidationError("Invalid email or password.")
        attrs["user"] = user
        return attrs


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            "id",
            "email",
            "role",
            "full_name",
            "college_university",
            "business_name",
            "contact_person",
            "phone",
            "location",
            "pan_number",
        ]