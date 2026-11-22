from django.contrib import admin
from django.urls import path, include
from marketplace import urls as marketplace_urls

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/users/", include("users.urls")),
    path("api/student/", include((marketplace_urls.student_patterns, "marketplace"), namespace="student")),
    path("api/business/", include((marketplace_urls.business_patterns, "marketplace"), namespace="business")),
]