from rest_framework import serializers
from .models import (
    BusinessProfile,
    Gig,
    GigApplication,
    Project,
    ProjectReview,
    StudentProfile,
)


class StudentProfileSerializer(serializers.ModelSerializer):
    full_name = serializers.CharField(source="user.full_name", required=False)
    email = serializers.EmailField(source="user.email", read_only=True)
    college_university = serializers.CharField(
        source="user.college_university", required=False
    )
    location = serializers.CharField(source="user.location", required=False)
    profile_completion = serializers.IntegerField(read_only=True)

    class Meta:
        model = StudentProfile
        fields = [
            "id",
            "full_name",
            "email",
            "college_university",
            "location",
            "program",
            "semester",
            "bio",
            "skills",
            "portfolio_url",
            "is_verified",
            "verified_date",
            "profile_completion",
        ]
        read_only_fields = ["is_verified", "verified_date"]

    def update(self, instance, validated_data):
        user_data = validated_data.pop("user", {})
        for attr, value in user_data.items():
            setattr(instance.user, attr, value)
        instance.user.save()

        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        return instance


class BusinessProfileSerializer(serializers.ModelSerializer):
    email = serializers.EmailField(source="user.email", read_only=True)
    location = serializers.CharField(source="user.location", required=False)

    class Meta:
        model = BusinessProfile
        fields = [
            "id",
            "email",
            "location",
            "business_type",
            "about",
            "is_verified",
        ]
        read_only_fields = ["is_verified"]

    def update(self, instance, validated_data):
        user_data = validated_data.pop("user", {})
        for attr, value in user_data.items():
            setattr(instance.user, attr, value)
        instance.user.save()

        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        return instance


class GigSerializer(serializers.ModelSerializer):
    business_name = serializers.CharField(
        source="business.email", read_only=True
    )
    applicants_count = serializers.IntegerField(read_only=True)
    has_applied = serializers.BooleanField(read_only=True)

    class Meta:
        model = Gig
        fields = [
            "id",
            "business",
            "business_name",
            "title",
            "description",
            "deliverables",
            "required_skills",
            "category",
            "budget_npr",
            "duration_days",
            "deadline",
            "location",
            "is_remote",
            "status",
            "applicants_count",
            "has_applied",
            "created_at",
        ]
        read_only_fields = ["business", "status", "created_at"]


class GigApplicationSerializer(serializers.ModelSerializer):
    gig_title = serializers.CharField(source="gig.title", read_only=True)
    business_name = serializers.CharField(
        source="gig.business.email", read_only=True
    )
    student_name = serializers.CharField(source="student.full_name", read_only=True)
    student_college = serializers.CharField(
        source="student.college_university", read_only=True
    )
    student_skills = serializers.SerializerMethodField()
    student_rating = serializers.SerializerMethodField()
    verified_projects_count = serializers.SerializerMethodField()

    class Meta:
        model = GigApplication
        fields = [
            "id",
            "gig",
            "gig_title",
            "business_name",
            "student",
            "student_name",
            "student_college",
            "student_skills",
            "student_rating",
            "verified_projects_count",
            "cover_message",
            "status",
            "applied_at",
        ]
        read_only_fields = ["gig", "student", "status", "applied_at"]

    def get_student_skills(self, obj):
        profile = getattr(obj.student, "student_profile", None)
        return profile.skills if profile else []

    def get_student_rating(self, obj):
        reviews = obj.student.career_passport_reviews.all()
        if not reviews.exists():
            return 0.0
        avg = sum(float(r.rating) for r in reviews) / reviews.count()
        return round(avg, 1)

    def get_verified_projects_count(self, obj):
        return obj.student.career_passport_reviews.count()


class ProjectReviewSerializer(serializers.ModelSerializer):
    gig_title = serializers.CharField(source="project.gig.title", read_only=True)
    business_name = serializers.CharField(
        source="business.email", read_only=True
    )
    business_location = serializers.CharField(
        source="business.location", read_only=True
    )
    duration_days = serializers.IntegerField(
        source="project.gig.duration_days", read_only=True
    )
    skills = serializers.JSONField(
        source="project.gig.required_skills", read_only=True
    )
    submission_link = serializers.URLField(
        source="project.submission_link", read_only=True
    )
    completed_at = serializers.DateTimeField(
        source="project.completed_at", read_only=True
    )

    class Meta:
        model = ProjectReview
        fields = [
            "id",
            "project",
            "gig_title",
            "business_name",
            "business_location",
            "role_title",
            "skills",
            "duration_days",
            "rating",
            "review_comment",
            "submission_link",
            "completed_at",
            "created_at",
        ]
        read_only_fields = ["project", "created_at"]


class ProjectSerializer(serializers.ModelSerializer):
    gig_title = serializers.CharField(source="gig.title", read_only=True)
    budget_npr = serializers.IntegerField(source="gig.budget_npr", read_only=True)
    deadline = serializers.DateField(source="gig.deadline", read_only=True)
    deliverables = serializers.JSONField(source="gig.deliverables", read_only=True)
    business_name = serializers.CharField(
        source="business.email", read_only=True
    )
    student_name = serializers.CharField(source="student.full_name", read_only=True)
    has_review = serializers.SerializerMethodField()

    class Meta:
        model = Project
        fields = [
            "id",
            "gig",
            "gig_title",
            "budget_npr",
            "deadline",
            "deliverables",
            "business_name",
            "student_name",
            "status",
            "submission_link",
            "submission_note",
            "submitted_at",
            "completed_at",
            "has_review",
            "created_at",
        ]
        read_only_fields = [
            "gig",
            "student",
            "business",
            "status",
            "submitted_at",
            "completed_at",
            "created_at",
        ]

    def get_has_review(self, obj):
        return hasattr(obj, "review")