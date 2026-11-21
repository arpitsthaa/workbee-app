from django.urls import path
from . import views

urlpatterns = [
    path("register/student/", views.register_student, name="register-student"),
    path("register/business/", views.register_business, name="register-business"),
    path("login/", views.login_user, name="login"),
    path("forgot-password/", views.forgot_password, name="forgot-password"),
    path("profile/", views.get_profile, name="profile"),
]