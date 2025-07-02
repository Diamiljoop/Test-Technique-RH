from django.db import models
from django.contrib.auth.models import AbstractUser
from django.db.models.signals import post_migrate
from django.dispatch import receiver
from django.contrib.auth import get_user_model

# --------------------------------------------
# 1. UTILISATEUR PERSONNALISÉ
# --------------------------------------------

class User(AbstractUser):
    ROLE_CHOICES = (
        ('gestionnaire', 'Gestionnaire'),
        ('utilisateur', 'Utilisateur'),
    )
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='utilisateur')
    is_active = models.BooleanField(default=True)  # activation/désactivation

    def __str__(self):
        return f"{self.username} ({self.role})"

@receiver(post_migrate)
def create_default_users(sender, **kwargs):
    User = get_user_model()
    # Création du gestionnaire
    if not User.objects.filter(username='ges').exists():
        User.objects.create_user(
            username='ges',
            email='ges@gmail.com',
            password='ges',
            role='gestionnaire',
            is_active=True
        )
    # Création du superuser
    if not User.objects.filter(username='admin').exists():
        User.objects.create_superuser(
            username='admin',
            email='admin@admin.com',
            password='admin',
            role='superadmin',
            is_active=True
        )

# --------------------------------------------
# 2. PROJET
# --------------------------------------------

class Projet(models.Model):
    nom = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    date_creation = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.nom

# --------------------------------------------
# 3. TÂCHE
# --------------------------------------------

class Tache(models.Model):
    STATUT_CHOICES = (
        ('en_attente', 'En attente'),
        ('en_cours', 'En cours'),
        ('terminee', 'Terminée'),
    )

    titre = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    statut = models.CharField(max_length=20, choices=STATUT_CHOICES, default='en_attente')
    date_creation = models.DateTimeField(auto_now_add=True)

    projet = models.ForeignKey(Projet, on_delete=models.CASCADE, related_name='taches')
    assignee = models.ForeignKey(User, on_delete=models.CASCADE, related_name='taches')

    def __str__(self):
        return f"{self.titre} - {self.statut}"


# Create your models here.
