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
]

business_patterns = [
    path("dashboard/", BusinessDashboardView.as_view(), name="dashboard"),
    path("profile/", BusinessProfileView.as_view(), name="profile"),
    path("gigs/", BusinessGigsView.as_view(), name="gigs"),
    path("gigs/<int:pk>/", BusinessGigDetailView.as_view(), name="gig-detail"),
    path("projects/", BusinessProjectsView.as_view(), name="projects"),
    path("projects/<int:pk>/review-work/", ReviewProjectWorkView.as_view(), name="review-work"),
    path("projects/<int:pk>/rate/", RateStudentProjectView.as_view(), name="rate-student"),
    path(
        "applications/<int:pk>/status/",
        UpdateApplicationStatusView.as_view(),
        name="update-application-status",
    ),
]

urlpatterns = student_patterns + business_patterns
