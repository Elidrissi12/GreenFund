# Solution au problème Gradle avec espaces dans le chemin

## Problème
L'erreur indique que Gradle ne peut pas créer les dossiers car `C:\Users\ABDO` existe déjà comme **fichier** au lieu d'un dossier.

## Solutions

### Solution 1 : Vérifier et supprimer le fichier parasite (RECOMMANDÉ)

Ouvrez PowerShell en tant qu'administrateur et exécutez :

```powershell
# Vérifier ce qui existe à C:\Users\ABDO
Get-Item 'C:\Users\ABDO' -ErrorAction SilentlyContinue | Format-List *

# Si c'est un fichier, le supprimer
Remove-Item 'C:\Users\ABDO' -Force -ErrorAction SilentlyContinue

# Ensuite, nettoyer et relancer Flutter
cd "C:\Users\ABDO EL IDRISSI\Desktop\GreenFund"
flutter clean
flutter pub get
flutter run
```

### Solution 2 : Déplacer le projet dans un chemin sans espaces

```powershell
# Créer un dossier dev
mkdir C:\dev -ErrorAction SilentlyContinue

# Copier le projet
robocopy "C:\Users\ABDO EL IDRISSI\Desktop\GreenFund" "C:\dev\GreenFund" /E

# Aller dans le nouveau dossier
cd C:\dev\GreenFund

# Nettoyer et lancer
flutter clean
flutter pub get
flutter run -d chrome
```

### Solution 3 : Utiliser Chrome au lieu de l'émulateur Android (TEMPORAIRE)

Si vous voulez juste tester rapidement sans résoudre le problème Gradle :

```powershell
cd "C:\Users\ABDO EL IDRISSI\Desktop\GreenFund"
flutter run -d chrome
```

Chrome ne nécessite pas la compilation Android/Gradle.

---

**Note** : La Solution 1 est la meilleure car elle résout le problème à la racine.
