from django.contrib import admin
from django.http import JsonResponse
from django.urls import path, include
from students import urls as students_urls
from businesses import urls as businesses_urls

def health(_request):
    return JsonResponse({"status": "ok"})

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/health/", health, name="health"),
    path("api/users/", include("users.urls")),
    path("api/student/", include((students_urls.student_patterns, "students"), namespace="students")),
    path("api/business/", include((businesses_urls.business_patterns, "businesses"), namespace="businesses")),
]
