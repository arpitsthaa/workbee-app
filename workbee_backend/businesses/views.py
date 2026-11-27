from django.db import DatabaseError
from django.db.models import Avg, Count, Exists, OuterRef, Q
from django.shortcuts import get_object_or_404
from django.utils import timezone
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from marketplace.models import Gig, GigApplication, Project, ProjectReview, BusinessProfile
from marketplace.serializers import (
    BusinessProfileSerializer,
    GigApplicationSerializer,
    GigSerializer,
    ProjectReviewSerializer,
    ProjectSerializer,
)


class BusinessDashboardView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        profile, _ = BusinessProfile.objects.get_or_create(user=user)

        gigs = Gig.objects.filter(business=user)
        applications = GigApplication.objects.filter(gig__business=user).select_related(
            "student", "student__student_profile"
        ).prefetch_related("student__career_passport_reviews")
        projects = Project.objects.filter(business=user).select_related(
            "gig", "business"
        ).prefetch_related("review")

        return Response(
            {
                "business_name": user.email or "Business Workspace",
                "location": user.location or "",
                "is_verified": profile.is_verified,
                "stats": {
                    "active_gigs": gigs.filter(status="OPEN").count(),
                    "new_applicants": applications.filter(status="PENDING").count(),
                    "projects_in_progress": projects.exclude(status="APPROVED").count(),
                    "completed_projects": projects.filter(status="APPROVED").count(),
                },
                "recent_applications": GigApplicationSerializer(
                    applications[:5], many=True
                ).data,
            }
        )


class BusinessProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = BusinessProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        profile, _ = BusinessProfile.objects.get_or_create(user=self.request.user)
        return profile


class BusinessGigsView(generics.ListCreateAPIView):
    serializer_class = GigSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Gig.objects.filter(business=self.request.user)

    def perform_create(self, serializer):
        serializer.save(business=self.request.user)


class BusinessGigDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = GigSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Gig.objects.filter(business=self.request.user)


class UpdateApplicationStatusView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, pk):
        application = get_object_or_404(
            GigApplication, pk=pk, gig__business=request.user
        )
        new_status = request.data.get("status", "").upper()

        if new_status not in ["SHORTLISTED", "ACCEPTED", "REJECTED"]:
            return Response(
                {"message": "Invalid status. Use SHORTLISTED, ACCEPTED, or REJECTED."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        application.status = new_status
        application.save()

        project_data = None
        if new_status == "ACCEPTED":
            gig = application.gig
            gig.status = "IN_PROGRESS"
            gig.save()

            project, _ = Project.objects.get_or_create(
                gig=gig,
                defaults={
                    "student": application.student,
                    "business": request.user,
                    "status": "NOT_STARTED",
                },
            )
            project_data = ProjectSerializer(project).data

        return Response(
            {
                "message": f"Applicant marked as {new_status.title()}.",
                "application": GigApplicationSerializer(application).data,
                "project": project_data,
            }
        )


class BusinessProjectsView(generics.ListAPIView):
    serializer_class = ProjectSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Project.objects.filter(business=self.request.user).select_related(
            "gig", "business", "student"
        ).prefetch_related("review")


class BusinessApplicationsListView(generics.ListAPIView):
    serializer_class = GigApplicationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return GigApplication.objects.filter(
            gig__business=self.request.user
        ).select_related("student", "student__student_profile").prefetch_related(
            "student__career_passport_reviews"
        )


class ReviewProjectWorkView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        project = get_object_or_404(Project, pk=pk, business=request.user)
        action = request.data.get("action", "").lower()

        if action == "approve":
            project.status = "APPROVED"
            project.completed_at = timezone.now()
            project.gig.status = "CLOSED"
            project.gig.save()
            project.save()
            message = "Work approved! You can now rate the student."
        elif action == "request_changes":
            project.status = "CHANGES_REQUESTED"
            project.save()
            message = "Changes requested from the student."
        else:
            return Response(
                {"message": "Invalid action. Use 'approve' or 'request_changes'."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        return Response(
            {
                "message": message,
                "project": ProjectSerializer(project).data,
            }
        )


class RateStudentProjectView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        project = get_object_or_404(Project, pk=pk, business=request.user)

        if project.status != "APPROVED":
            return Response(
                {"message": "You must approve the project before rating the student."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if hasattr(project, "review"):
            return Response(
                {"message": "This project has already been rated."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        serializer = ProjectReviewSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(
            project=project,
            student=project.student,
            business=request.user,
        )

        return Response(
            {
                "message": "Review submitted and added to student's Career Passport!",
                "review": serializer.data,
            },
            status=status.HTTP_201_CREATED,
        )
