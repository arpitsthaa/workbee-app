from django.conf import settings
from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models


class StudentProfile(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="student_profile",
    )
    program = models.CharField(max_length=100, blank=True, default="")  # e.g., BCA
    semester = models.CharField(max_length=50, blank=True, default="")  # e.g., Semester 4
    bio = models.TextField(blank=True, default="")
    skills = models.JSONField(default=list, blank=True)  # e.g., ["Canva", "Figma"]
    portfolio_url = models.URLField(blank=True, default="")
    is_verified = models.BooleanField(default=False)
    verified_date = models.DateField(null=True, blank=True)

    @property
    def profile_completion(self):
        fields = [
            self.user.full_name,
            self.user.college_university,
            self.user.location,
            self.program,
            self.semester,
            self.bio,
            bool(self.skills),
            self.portfolio_url,
        ]
        filled = sum(1 for item in fields if item)
        return int((filled / len(fields)) * 100)

    def __str__(self):
        return f"Student Profile: {self.user.full_name or self.user.email}"


class BusinessProfile(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="business_profile",
    )
    business_type = models.CharField(
        max_length=120, blank=True, default="Local business"
    )  # e.g., Restaurant · Local business
    about = models.TextField(blank=True, default="")
    is_verified = models.BooleanField(default=False)

    def __str__(self):
        return f"Business Profile: {self.user.email}"


class Gig(models.Model):
    STATUS_CHOICES = (
        ("OPEN", "Open"),
        ("IN_PROGRESS", "In Progress"),
        ("CLOSED", "Closed"),
    )

    business = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="posted_gigs",
    )
    title = models.CharField(max_length=200)
    description = models.TextField()
    deliverables = models.JSONField(default=list, blank=True)
    required_skills = models.JSONField(default=list, blank=True)
    category = models.CharField(max_length=100, default="Design & creative")
    budget_npr = models.PositiveIntegerField()
    duration_days = models.PositiveIntegerField(default=7)
    deadline = models.DateField()
    location = models.CharField(max_length=150)
    is_remote = models.BooleanField(default=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="OPEN")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.title} - {self.business.email}"


class GigApplication(models.Model):
    STATUS_CHOICES = (
        ("PENDING", "Pending"),
        ("SHORTLISTED", "Shortlisted"),
        ("ACCEPTED", "Accepted"),
        ("REJECTED", "Rejected"),
    )

    gig = models.ForeignKey(
        Gig,
        on_delete=models.CASCADE,
        related_name="applications",
    )
    student = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="gig_applications",
    )
    cover_message = models.TextField(blank=True, default='')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="PENDING")
    applied_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ("gig", "student")
        ordering = ["-applied_at"]

    def __str__(self):
        return f"{self.student.full_name or self.student.email} -> {self.gig.title}"


class Project(models.Model):
    STATUS_CHOICES = (
        ("IN_PROGRESS", "In Progress"),
        ("SUBMITTED", "Submitted"),
        ("CHANGES_REQUESTED", "Changes Requested"),
        ("APPROVED", "Approved"),
    )

    gig = models.OneToOneField(
        Gig,
        on_delete=models.CASCADE,
        related_name="project",
    )
    student = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="student_projects",
    )
    business = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="business_projects",
    )
    status = models.CharField(
        max_length=20, choices=STATUS_CHOICES, default="IN_PROGRESS"
    )
    submission_link = models.URLField(blank=True, default="")
    submission_note = models.TextField(blank=True, default="")
    submitted_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"Project: {self.gig.title} ({self.status})"


class ProjectReview(models.Model):
    project = models.OneToOneField(
        Project,
        on_delete=models.CASCADE,
        related_name="review",
    )
    student = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="career_passport_reviews",
    )
    business = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="given_reviews",
    )
    role_title = models.CharField(max_length=120, default="Student Freelancer")
    rating = models.DecimalField(
        max_digits=2,
        decimal_places=1,
        validators=[MinValueValidator(1.0), MaxValueValidator(5.0)],
    )
    review_comment = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.project.gig.title} - {self.rating}/5"