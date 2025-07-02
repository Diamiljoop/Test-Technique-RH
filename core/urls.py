from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from .views import UserViewSet, ProjetViewSet, TacheViewSet, UserMeView

router = DefaultRouter()
router.register(r'users', UserViewSet)
router.register(r'projets', ProjetViewSet)
router.register(r'taches', TacheViewSet)

urlpatterns = [
    path('users/me/', UserMeView.as_view(), name='user_me'),
    path('', include(router.urls)),
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),   # login
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]
