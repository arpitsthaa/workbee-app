from django.contrib import admin
from django.http import JsonResponse
from django.urls import path, include
from marketplace import urls as marketplace_urls

def health(_request):
    return JsonResponse({"status": "ok"})

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/health/", health, name="health"),
    path("api/users/", include("users.urls")),
    path("api/student/", include((marketplace_urls.student_patterns, "students"), namespace="students")),
    path("api/business/", include((marketplace_urls.business_patterns, "businesses"), namespace="businesses")),
]
