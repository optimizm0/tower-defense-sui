# 🤝 Guide de Contribution

Merci de votre intérêt pour contribuer à Tower Defense Sui !

## 🐛 Signaler un Bug

1. Vérifiez qu'il n'existe pas déjà dans les [Issues](https://github.com/VoxJusticia/tower-defense-sui/issues)
2. Créez une nouvelle issue avec:
   - **Titre clair** décrivant le problème
   - **Étapes pour reproduire** le bug
   - **Comportement attendu** vs **comportement observé**
   - **Screenshots** si applicable
   - **Environment** (navigateur, OS, etc.)

## 💡 Proposer une Amélioration

1. Ouvrez une [Discussion](https://github.com/VoxJusticia/tower-defense-sui/discussions)
2. Décrivez votre idée en détail
3. Expliquez pourquoi cette amélioration serait utile

## 🔧 Contribuer au Code

### Prérequis
- Sui CLI installé
- Connaissance de Move et JavaScript
- Git configuré

### Processus
1. **Fork** le projet
2. **Clone** votre fork
3. Créez une **branche** pour votre feature: `git checkout -b feature/ma-feature`
4. **Développez** et **testez** vos modifications
5. **Commit** avec des messages clairs: `git commit -m "feat: ajoute nouvelle fonctionnalité"`
6. **Push** vers votre fork: `git push origin feature/ma-feature`
7. Créez une **Pull Request**

### Standards de Code

#### Smart Contract (Move)
- Commentaires en anglais
- Tests pour chaque fonction publique
- Gestion d'erreurs appropriée
- Événements pour actions importantes

#### Frontend (HTML/CSS/JS)
- Code indenté proprement
- Variables et fonctions nommées clairement
- Responsive design
- Accessibilité (WCAG 2.1)

### Tests
```bash
# Smart contract
cd smart-contract
sui move test

# Frontend
# Tester manuellement sur différents navigateurs
