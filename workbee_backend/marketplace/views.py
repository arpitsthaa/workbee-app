from django.db.models import Q
from django.shortcuts import get_object_or_404
from django.utils import timezone
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import (
    BusinessProfile,
    Gig,
    GigApplication,
    Project,
    ProjectReview,
    StudentProfile,
)
from .serializers import (
    BusinessProfileSerializer,
    GigApplicationSerializer,
    GigSerializer,
    ProjectReviewSerializer,
    ProjectSerializer,
    StudentProfileSerializer,
)


class StudentDashboardView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        profile, _ = StudentProfile.objects.get_or_create(user=user)

        open_gigs = Gig.objects.filter(status="OPEN")
        if profile.skills:
            skill_query = Q()
            for skill in profile.skills:
                skill_query |= Q(required_skills__icontains=skill)
            recommended = open_gigs.filter(skill_query).distinct()[:5]
            if not recommended.exists():
                recommended = open_gigs[:5]
        else:
            recommended = open_gigs[:5]

        applications = GigApplication.objects.filter(student=user)
        projects = Project.objects.filter(student=user)
        reviews = ProjectReview.objects.filter(student=user)

        avg_rating = 0.0
        if reviews.exists():
            avg_rating = round(
                sum(float(r.rating) for r in reviews) / reviews.count(), 1
            )

        return Response(
            {
                "full_name": user.full_name or "Student",
                "is_verified": profile.is_verified,
                "profile_completion": profile.profile_completion,
                "recommended_gigs": GigSerializer(
                    recommended, many=True, context={"request": request}
                ).data,
                "applications_summary": {
                    "total": applications.count(),
                    "pending": applications.filter(status="PENDING").count(),
                    "shortlisted": applications.filter(status="SHORTLISTED").count(),
                },
                "projects_summary": {
                    "total": projects.count(),
                    "active": projects.exclude(status="APPROVED").count(),
                    "approved": projects.filter(status="APPROVED").count(),
                },
                "career_passport": {
                    "verified_projects": reviews.count(),
                    "average_rating": avg_rating,
                },
            }
        )


class StudentProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = StudentProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        profile, _ = StudentProfile.objects.get_or_create(user=self.request.user)
        return profile


class BrowseGigsView(generics.ListAPIView):
    serializer_class = GigSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        queryset = Gig.objects.filter(status="OPEN")
        search = self.request.query_params.get("search")
        category = self.request.query_params.get("category")
        max_budget = self.request.query_params.get("max_budget")

        if search:
            queryset = queryset.filter(
                Q(title__icontains=search)
                | Q(description__icontains=search)
                | Q(business__business_name__icontains=search)
                | Q(location__icontains=search)
            )
        if category:
            queryset = queryset.filter(category__iexact=category)
        if max_budget and max_budget.isdigit():
            queryset = queryset.filter(budget_npr__lte=int(max_budget))

        return queryset


class GigDetailView(generics.RetrieveAPIView):
    queryset = Gig.objects.all()
    serializer_class = GigSerializer
    permission_classes = [permissions.IsAuthenticated]


class ApplyForGigView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        if request.user.role != "student":
            return Response(
                {"message": "Only students can apply for gigs."},
                status=status.HTTP_403_FORBIDDEN,
            )

        gig = get_object_or_404(Gig, pk=pk, status="OPEN")
        if GigApplication.objects.filter(gig=gig, student=request.user).exists():
            return Response(
                {"message": "You have already applied for this gig."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        serializer = GigApplicationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(gig=gig, student=request.user)

        return Response(
            {
                "message": "Application submitted successfully!",
                "application": serializer.data,
            },
            status=status.HTTP_201_CREATED,
        )


class StudentWorkView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        applications = GigApplication.objects.filter(student=request.user)
        projects = Project.objects.filter(student=request.user)
        return Response(
            {
                "applications": GigApplicationSerializer(applications, many=True).data,
                "projects": ProjectSerializer(projects, many=True).data,
            }
        )


class SubmitProjectWorkView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        project = get_object_or_404(Project, pk=pk, student=request.user)
        submission_link = request.data.get("submission_link", "").strip()
        submission_note = request.data.get("submission_note", "").strip()

        if not submission_link:
            return Response(
                {"message": "Please provide a Canva or Google Drive link."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        project.submission_link = submission_link
        project.submission_note = submission_note
        project.status = "SUBMITTED"
        project.submitted_at = timezone.now()
        project.save()

        return Response(
            {
                "message": "Work submitted for business approval!",
                "project": ProjectSerializer(project).data,
            }
        )


class CareerPassportView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        profile, _ = StudentProfile.objects.get_or_create(user=user)
        reviews = ProjectReview.objects.filter(student=user)

        avg_rating = 0.0
        if reviews.exists():
            avg_rating = round(
                sum(float(r.rating) for r in reviews) / reviews.count(), 1
            )

        return Response(
            {
                "full_name": user.full_name,
                "college_university": user.college_university,
                "program": profile.program,
                "verified_projects_count": reviews.count(),
                "average_rating": avg_rating,
                "completed_projects": ProjectReviewSerializer(reviews, many=True).data,
            }
        )


class BusinessDashboardView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        profile, _ = BusinessProfile.objects.get_or_create(user=user)

        gigs = Gig.objects.filter(business=user)
        applications = GigApplication.objects.filter(gig__business=user)
        projects = Project.objects.filter(business=user)

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
                    "status": "IN_PROGRESS",
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
        return Project.objects.filter(business=self.request.user)


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