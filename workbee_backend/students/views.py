from django.db import DatabaseError
from django.db.models import Avg, Count, Exists, OuterRef, Q
from django.shortcuts import get_object_or_404
from django.utils import timezone
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from marketplace.models import Gig, GigApplication, Project, ProjectReview, StudentProfile
from marketplace.serializers import (
    GigApplicationSerializer,
    GigSerializer,
    ProjectReviewSerializer,
    ProjectSerializer,
    StudentProfileSerializer,
)


class StudentDashboardView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        try:
            user = request.user
            profile, _ = StudentProfile.objects.get_or_create(user=user)

            open_gigs = Gig.objects.filter(status="OPEN").select_related("business")
            open_gigs = open_gigs.annotate(applicants_count=Count("applications"))
            has_applied_subquery = GigApplication.objects.filter(
                gig=OuterRef("pk"), student=user
            )
            open_gigs = open_gigs.annotate(
                has_applied=Exists(has_applied_subquery)
            )

            skills = profile.skills if isinstance(profile.skills, list) else []
            if skills:
                skill_query = Q()
                for skill in skills:
                    skill_query |= Q(required_skills__icontains=skill)
                recommended = open_gigs.filter(skill_query).distinct()[:5]
                if not recommended.exists():
                    recommended = open_gigs[:5]
            else:
                recommended = open_gigs[:5]

            applications = GigApplication.objects.filter(student=user)
            projects = Project.objects.filter(student=user).select_related("gig", "business")
            reviews = ProjectReview.objects.filter(student=user).select_related("project", "business")

            app_agg = applications.aggregate(
                total=Count("id"),
                pending=Count("id", filter=Q(status="PENDING")),
                shortlisted=Count("id", filter=Q(status="SHORTLISTED")),
            )
            proj_agg = projects.aggregate(
                total=Count("id"),
                active=Count("id", filter=~Q(status="APPROVED")),
                approved=Count("id", filter=Q(status="APPROVED")),
            )

            rating_agg = reviews.aggregate(
                avg_rating=Avg("rating"),
                count=Count("id"),
            )
            avg_rating = (
                round(rating_agg["avg_rating"], 1) if rating_agg["count"] else 0.0
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
                        "total": app_agg["total"],
                        "pending": app_agg["pending"],
                        "shortlisted": app_agg["shortlisted"],
                    },
                    "projects_summary": {
                        "total": proj_agg["total"],
                        "active": proj_agg["active"],
                        "approved": proj_agg["approved"],
                    },
                    "career_passport": {
                        "verified_projects": rating_agg["count"],
                        "average_rating": avg_rating,
                    },
                }
            )
        except DatabaseError as exc:
            return Response(
                {"error": "Dashboard unavailable due to a database error."},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )
        except Exception as exc:
            return Response(
                {"error": "Dashboard unavailable. Please try again later."},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
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
        try:
            user = self.request.user
            queryset = Gig.objects.filter(status="OPEN").select_related("business")
            queryset = queryset.annotate(applicants_count=Count("applications"))
            has_applied_subquery = GigApplication.objects.filter(
                gig=OuterRef("pk"), student=user
            )
            queryset = queryset.annotate(
                has_applied=Exists(has_applied_subquery)
            )

            search = self.request.query_params.get("search")
            category = self.request.query_params.get("category")
            max_budget = self.request.query_params.get("max_budget")

            if search:
                queryset = queryset.filter(
                    Q(title__icontains=search)
                    | Q(description__icontains=search)
                    | Q(business__email__icontains=search)
                    | Q(location__icontains=search)
                )
            if category:
                queryset = queryset.filter(category__iexact=category)
            if max_budget and max_budget.isdigit():
                queryset = queryset.filter(budget_npr__lte=int(max_budget))

            return queryset
        except DatabaseError:
            return Gig.objects.none()


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
        applications = GigApplication.objects.filter(student=request.user).select_related(
            "gig", "gig__business"
        )
        projects = Project.objects.filter(student=request.user).select_related(
            "gig", "business"
        ).prefetch_related("review")
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


class UpdateProjectStatusView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        project = get_object_or_404(Project, pk=pk, student=request.user)
        new_status = request.data.get("status", "").upper()
        if new_status not in ["NOT_STARTED", "IN_PROGRESS", "COMPLETED"]:
            return Response(
                {"message": "Invalid status. Use NOT_STARTED, IN_PROGRESS, or COMPLETED."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        project.status = new_status
        project.save()
        return Response(
            {
                "message": f"Project status updated to {new_status.title()}.",
                "project": ProjectSerializer(project).data,
            }
        )


class CareerPassportView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        profile, _ = StudentProfile.objects.get_or_create(user=user)
        reviews = ProjectReview.objects.filter(student=user).select_related(
            "project__gig"
        )

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


class WithdrawApplicationView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def delete(self, request, pk):
        application = get_object_or_404(GigApplication, pk=pk, student=request.user)

        if application.status not in ["PENDING", "SHORTLISTED"]:
            return Response(
                {"message": f"Cannot withdraw application with status '{application.status}'."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        gig_id = application.gig_id
        application.delete()

        return Response(
            {
                "message": "Application withdrawn successfully.",
                "gig_id": gig_id,
            },
            status=status.HTTP_200_OK,
        )
