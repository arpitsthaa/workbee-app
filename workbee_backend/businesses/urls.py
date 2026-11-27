from django.urls import path

from .views import (
    BusinessApplicationsListView,
    BusinessDashboardView,
    BusinessGigDetailView,
    BusinessGigsView,
    BusinessProfileView,
    BusinessProjectsView,
    RateStudentProjectView,
    ReviewProjectWorkView,
    UpdateApplicationStatusView,
)

business_patterns = [
    path("dashboard/", BusinessDashboardView.as_view(), name="dashboard"),
    path("profile/", BusinessProfileView.as_view(), name="profile"),
    path("gigs/", BusinessGigsView.as_view(), name="gigs"),
    path("gigs/<int:pk>/", BusinessGigDetailView.as_view(), name="gig-detail"),
    path("projects/", BusinessProjectsView.as_view(), name="projects"),
    path("projects/<int:pk>/review-work/", ReviewProjectWorkView.as_view(), name="review-work"),
    path("projects/<int:pk>/rate/", RateStudentProjectView.as_view(), name="rate-student"),
    path("applications/", BusinessApplicationsListView.as_view(), name="applications-list"),
    path(
        "applications/<int:pk>/status/",
        UpdateApplicationStatusView.as_view(),
        name="update-application-status",
    ),
]
