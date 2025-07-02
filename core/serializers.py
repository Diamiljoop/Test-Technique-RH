from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from .models import User, Projet, Tache

# Serializer Utilisateur (sans mot de passe)
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'role', 'is_active']


# Serializer pour la création d'utilisateurs
class UserCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, validators=[validate_password])
    password_confirm = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'password', 'password_confirm', 'role', 'is_active']

    def validate(self, attrs):
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError("Les mots de passe ne correspondent pas")
        return attrs

    def create(self, validated_data):
        validated_data.pop('password_confirm')
        password = validated_data.pop('password')
        user = User.objects.create_user(**validated_data)
        user.set_password(password)
        user.is_active = True  # Activer automatiquement les nouveaux utilisateurs
        user.save()
        return user


# Serializer Tâche (inclut les données essentielles de l'assignee)
class TacheSerializer(serializers.ModelSerializer):
    assignee = UserSerializer(read_only=True)  # imbriqué en lecture seule
    assignee_id = serializers.PrimaryKeyRelatedField(
        queryset=User.objects.filter(is_active=True),  # Tous les utilisateurs actifs
        write_only=True,
        source='assignee',
        required=False,  # Permettre la création sans assignee
        allow_null=True
    )
    projet_id = serializers.PrimaryKeyRelatedField(
        queryset=Projet.objects.all(),
        write_only=True,
        source='projet'
    )
    projet = serializers.PrimaryKeyRelatedField(read_only=True)

    class Meta:
        model = Tache
        fields = ['id', 'titre', 'description', 'statut', 'date_creation', 'assignee', 'assignee_id', 'projet_id', 'projet']

    def validate_assignee_id(self, value):
        """Validation personnalisée pour assignee_id"""
        if value is None:
            return value
        if not value.is_active:
            raise serializers.ValidationError("L'utilisateur assigné doit être actif")
        return value


# Serializer Projet (avec les tâches imbriquées)
class ProjetSerializer(serializers.ModelSerializer):
    taches = TacheSerializer(many=True, read_only=True)

    class Meta:
        model = Projet
        fields = ['id', 'nom', 'description', 'date_creation', 'taches']
