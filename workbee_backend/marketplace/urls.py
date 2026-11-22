from django.urls import path
from .views import (
    ApplyForGigView,
    BrowseGigsView,
    BusinessDashboardView,
    BusinessGigDetailView,
    BusinessGigsView,
    BusinessProfileView,
    BusinessProjectsView,
    CareerPassportView,
    GigDetailView,
    RateStudentProjectView,
    ReviewProjectWorkView,
    StudentDashboardView,
    StudentProfileView,
    StudentWorkView,
    SubmitProjectWorkView,
    UpdateApplicationStatusView,
)

urlpatterns = [
    # Student endpoints
    path("student/dashboard/", StudentDashboardView.as_view(), name="student-dashboard"),
    path("student/profile/", StudentProfileView.as_view(), name="student-profile"),
    path("student/work/", StudentWorkView.as_view(), name="student-work"),
    path("student/passport/", CareerPassportView.as_view(), name="career-passport"),

    # Gigs & Applications
    path("gigs/", BrowseGigsView.as_view(), name="browse-gigs"),
    path("gigs/<int:pk>/", GigDetailView.as_view(), name="gig-detail"),
    path("gigs/<int:pk>/apply/", ApplyForGigView.as_view(), name="apply-gig"),

    # Projects & Reviews
    path("projects/<int:pk>/submit/", SubmitProjectWorkView.as_view(), name="submit-work"),
    path("projects/<int:pk>/review-work/", ReviewProjectWorkView.as_view(), name="review-work"),
    path("projects/<int:pk>/rate/", RateStudentProjectView.as_view(), name="rate-student"),

    # Business endpoints
    path("business/dashboard/", BusinessDashboardView.as_view(), name="business-dashboard"),
    path("business/profile/", BusinessProfileView.as_view(), name="business-profile"),
    path("business/gigs/", BusinessGigsView.as_view(), name="business-gigs"),
    path("business/gigs/<int:pk>/", BusinessGigDetailView.as_view(), name="business-gig-detail"),
    path("business/projects/", BusinessProjectsView.as_view(), name="business-projects"),
    path(
        "applications/<int:pk>/status/",
        UpdateApplicationStatusView.as_view(),
        name="update-application-status",
    ),
]