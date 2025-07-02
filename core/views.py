from django.shortcuts import render
from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import User, Projet, Tache
from .serializers import UserSerializer, UserCreateSerializer, ProjetSerializer, TacheSerializer
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated

# Permission basique pour commencer (à affiner ensuite)
class IsGestionnaire(permissions.BasePermission):
    def has_permission(self, request, view):
        # Permettre aux super utilisateurs, gestionnaires et superadmin (champ role)
        return request.user.is_authenticated and (
            request.user.is_superuser or 
            getattr(request.user, 'role', None) in ['gestionnaire', 'superadmin']
        )

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    permission_classes = [IsGestionnaire]  # Seuls les gestionnaires gèrent les utilisateurs

    def get_serializer_class(self):
        if self.action == 'create':
            return UserCreateSerializer
        return UserSerializer

    @action(detail=True, methods=['post'])
    def activate(self, request, pk=None):
        """Activer un utilisateur"""
        try:
            user = self.get_object()
            user.is_active = True
            user.save()
            return Response({'message': f'Utilisateur {user.username} activé avec succès'})
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['post'])
    def deactivate(self, request, pk=None):
        """Désactiver un utilisateur"""
        try:
            user = self.get_object()
            user.is_active = False
            user.save()
            return Response({'message': f'Utilisateur {user.username} désactivé avec succès'})
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['put', 'patch'])
    def update_role(self, request, pk=None):
        """Mettre à jour le rôle d'un utilisateur"""
        try:
            user = self.get_object()
            new_role = request.data.get('role')
            if new_role not in ['gestionnaire', 'utilisateur']:
                return Response({'error': 'Rôle invalide'}, status=status.HTTP_400_BAD_REQUEST)
            
            user.role = new_role
            user.save()
            serializer = self.get_serializer(user)
            return Response(serializer.data)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

class ProjetViewSet(viewsets.ModelViewSet):
    queryset = Projet.objects.all()
    serializer_class = ProjetSerializer
    permission_classes = [permissions.IsAuthenticated]  # Tous utilisateurs connectés

class TacheViewSet(viewsets.ModelViewSet):
    queryset = Tache.objects.all()
    serializer_class = TacheSerializer
    permission_classes = [permissions.IsAuthenticated]

class UserMeView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request):
        return Response(UserSerializer(request.user).data)

