from django.contrib import admin
from .models import (
    BusinessProfile,
    Gig,
    GigApplication,
    Project,
    ProjectReview,
    StudentProfile,
)


@admin.register(StudentProfile)
class StudentProfileAdmin(admin.ModelAdmin):
    list_display = ("user", "program", "semester", "is_verified")
    list_filter = ("is_verified",)
    search_fields = ("user__email", "user__full_name")


@admin.register(BusinessProfile)
class BusinessProfileAdmin(admin.ModelAdmin):
    list_display = ("user", "business_type", "is_verified")
    list_filter = ("is_verified",)
    search_fields = ("user__email", "user__business_name")


@admin.register(Gig)
class GigAdmin(admin.ModelAdmin):
    list_display = ("title", "business", "budget_npr", "deadline", "status")
    list_filter = ("status", "category", "is_remote")
    search_fields = ("title", "business__business_name", "location")


@admin.register(GigApplication)
class GigApplicationAdmin(admin.ModelAdmin):
    list_display = ("gig", "student", "status", "applied_at")
    list_filter = ("status",)


@admin.register(Project)
class ProjectAdmin(admin.ModelAdmin):
    list_display = ("gig", "student", "business", "status", "submitted_at")
    list_filter = ("status",)


@admin.register(ProjectReview)
class ProjectReviewAdmin(admin.ModelAdmin):
    list_display = ("project", "student", "business", "rating", "created_at")