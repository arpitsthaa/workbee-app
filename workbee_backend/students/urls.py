from django.urls import path

from .views import (
    ApplyForGigView,
    BrowseGigsView,
    CareerPassportView,
    GigDetailView,
    StudentDashboardView,
    StudentProfileView,
    StudentWorkView,
    SubmitProjectWorkView,
    UpdateProjectStatusView,
    WithdrawApplicationView,
)

student_patterns = [
    path("dashboard/", StudentDashboardView.as_view(), name="dashboard"),
    path("profile/", StudentProfileView.as_view(), name="profile"),
    path("work/", StudentWorkView.as_view(), name="work"),
    path("passport/", CareerPassportView.as_view(), name="passport"),
    path("gigs/", BrowseGigsView.as_view(), name="gigs"),
    path("gigs/<int:pk>/", GigDetailView.as_view(), name="gig-detail"),
    path("gigs/<int:pk>/apply/", ApplyForGigView.as_view(), name="apply-gig"),
    path("applications/<int:pk>/withdraw/", WithdrawApplicationView.as_view(), name="withdraw-application"),
    path("projects/<int:pk>/submit/", SubmitProjectWorkView.as_view(), name="submit-work"),
    path(
        "projects/<int:pk>/status/",
        UpdateProjectStatusView.as_view(),
        name="update-project-status",
    ),
]
