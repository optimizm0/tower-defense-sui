[![GitHub stars](https://img.shields.io/github/stars/VoxJusticia/tower-defense-sui)](https://github.com/VoxJusticia/tower-defense-sui/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/VoxJusticia/tower-defense-sui)](https://github.com/VoxJusticia/tower-defense-sui/network)
[![GitHub issues](https://img.shields.io/github/issues/VoxJusticia/tower-defense-sui)](https://github.com/VoxJustica/tower-defense-sui/issues)
[![Live Demo](https://img.shields.io/badge/demo-online-green)](https://VoxJusticia.github.io/tower-defense-sui)


# tower-defense-sui
Basic gambling tower defense game on SUI
AI-generated

# 🏰 Tower Defense - Sui Blockchain Game

> **Un jeu de tower defense décentralisé où les joueurs parient sur leur survie**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Sui Network](https://img.shields.io/badge/Blockchain-Sui-blue)](https://sui.io/)
[![Made with Move](https://img.shields.io/badge/Smart%20Contract-Move-green)](https://move-language.github.io/)

## 🎮 **Aperçu du Jeu**

Tower Defense est un jeu de stratégie et de paris décentralisé construit sur la blockchain Sui. Les joueurs créent un héros avec des caractéristiques aléatoires, parient sur le nombre de niveaux qu'ils pensent pouvoir compléter, et affrontent des vagues de monstres de plus en plus puissants.

### **Mécaniques Principales**
- 🛡️ **Héros personnalisé** avec HP, dégâts, vitesse d'attaque et résistance
- 👹 **Monstres évolutifs** qui deviennent 10% plus forts à chaque niveau
- 👑 **Boss fights** tous les 10 niveaux (4x plus puissants)
- 💰 **Système de paris** avec gains basés sur la performance
- ⬆️ **Améliorations** disponibles tous les 25 niveaux
- 🏆 **Récompenses calculées uniquement à la fin**

## 🚀 **Démo en Direct**

- **🎮 [Jouer Maintenant](https://VoxJusticia.github.io/tower-defense-sui)**
- **📱 [Version Mobile](https://VoxJusticia.github.io/tower-defense-sui)**

## 📁 **Structure du Projet**

```
tower-defense-sui/
├── 📄 README.md                 # Cette documentation
├── 📄 LICENSE                   # Licence MIT
├── 📄 CONTRIBUTING.md           # Guide de contribution
├── 📄 CHANGELOG.md              # Historique des versions
│
├── 📁 smart-contract/           # Smart contract Move
│   ├── 📄 Move.toml            # Configuration Move
│   ├── 📁 sources/
│   │   └── 📄 game.move        # Contrat principal du jeu
│   └── 📁 tests/
│       └── 📄 game_tests.move  # Tests unitaires
│
├── 📁 frontend/                 # Interface web
│   ├── 📄 index.html           # Page principale
│   ├── 📁 assets/
│   │   ├── 📁 css/
│   │   ├── 📁 js/
│   │   └── 📁 images/
│   └── 📄 manifest.json        # PWA manifest
│
├── 📁 docs/                     # Documentation
│   ├── 📄 DEPLOY.md            # Guide de déploiement
│   ├── 📄 API.md               # Documentation API
│   └── 📁 images/              # Screenshots & diagrammes
│
└── 📁 .github/                 # Configuration GitHub
    ├── 📁 workflows/
    │   └── 📄 deploy.yml       # CI/CD automatique
    └── 📄 ISSUE_TEMPLATE.md    # Template pour les issues
```

## 🛠️ **Installation & Développement Local**

### **Prérequis**
- [Sui CLI](https://docs.sui.io/build/install) v1.0+
- [Node.js](https://nodejs.org/) v16+ (pour le serveur de dev)
- [Git](https://git-scm.com/)

### **1. Cloner le Projet**
```bash
git clone https://github.com/votre-username/tower-defense-sui.git
cd tower-defense-sui
```

### **2. Déployer le Smart Contract**
```bash
cd smart-contract
sui move build
sui client publish --gas-budget 100000000
```

### **3. Lancer l'Interface Web**
```bash
cd ../frontend
python3 -m http.server 8000
# Ou avec Node.js: npx serve .
```

### **4. Accéder au Jeu**
Ouvrez [http://localhost:8000](http://localhost:8000) dans votre navigateur.

## 🎯 **Comment Jouer**

### **Étape 1: Connexion**
1. Connectez votre wallet Sui
2. Assurez-vous d'avoir des tokens SUI

### **Étape 2: Configuration**
1. **Montant du pari**: Minimum 100 SUI
2. **Niveau cible**: Nombre de niveaux que vous pensez atteindre
3. Cliquez sur "🚀 Commencer le Jeu"

### **Étape 3: Combat**
- Votre héros a des stats aléatoirement générées (faibles au début)
- Cliquez "⚔️ Combattre" pour attaquer le monstre
- Les monstres deviennent 25% plus forts à chaque niveau
- Boss fights tous les 10 niveaux

### **Étape 4: Stratégie**
- **Améliorations**: Disponibles tous les 25 niveaux
  - ❤️ +50 HP (soigne complètement)
  - ⚔️ +10 Dégâts
  - ⚡ +1 Vitesse d'attaque
  - 🛡️ +5% Résistance
- Maximum 4 améliorations par partie

### **Étape 5: Gains**
- **Succès**: Atteignez votre niveau cible → Gains = `Pari × (1 + Niveaux/50) - House Edge (5%)`
- **Échec**: Héros mort → Vous perdez votre pari
- **Retraite**: Abandonner → Vous perdez votre pari

## 💡 **Stratégies Gagnantes**

### **🎯 Pour les Joueurs**
- Commencez avec des objectifs modestes (niveaux 5-10)
- Investissez dans les HP en priorité (survie)
- Les améliorations aux niveaux 25/50 sont cruciales
- Boss fights = moments critiques

### **🏦 Avantage de la Maison**
- Progression des monstres (+10% par niveau)
- Stats de héros faibles au début
- House edge de 5%
- Gains plafonnés à 150% du pari

## 📊 **Économie du Jeu**

### **Calcul des Gains**
```
Multiplicateur = 1 + (Niveaux Complétés / 50)
Gain Brut = Pari × Multiplicateur
House Edge = Gain Brut × 5%
Gain Net = Gain Brut - House Edge
Gain Final = Min(Gain Net, Pari × 1.5)
```

### **Exemples**
| Pari | Niveaux | Gain Brut | House Edge | Gain Net | Profit Maison |
|------|---------|-----------|------------|----------|---------------|
| 100  | 5       | 105       | 10.5       | 94.5     | +5.5          |
| 100  | 10      | 110       | 11         | 99       | +1            |
| 100  | 20      | 120       | 12         | 108      | -8            |
| 100  | 50      | 150       | 15         | 135      | -35           |

## 🔧 **Configuration Avancée**

### **Smart Contract**
Variables ajustables dans `game.move`:
```move
const MONSTER_SCALING_RATE: u64 = 10;     // +10% par niveau
const BOSS_LEVEL_INTERVAL: u64 = 10;      // Boss tous les 10 niveaux
const UPGRADE_LEVEL_INTERVAL: u64 = 25;   // Upgrades tous les 25 niveaux
const MAX_UPGRADES: u64 = 4;              // Maximum 4 upgrades
```

### **Interface Web**
Personnalisation dans `index.html`:
- Thèmes et couleurs
- Emojis des monstres
- Messages de log
- Animations

## 🚀 **Déploiement en Production**

### **Automatique (Recommandé)**
Le déploiement se fait automatiquement via GitHub Actions:
1. Push sur `main` → Déploiement auto sur GitHub Pages
2. Smart contract déployé sur Sui Mainnet
3. Interface accessible via `username.github.io/tower-defense-sui`

### **Manuel**
```bash
# Construire le smart contract
sui move build

# Déployer sur Sui Mainnet
sui client publish --gas-budget 100000000 --network mainnet

# Déployer l'interface
# (Voir DEPLOY.md pour les détails)
```

## 🧪 **Tests**

### **Smart Contract**
```bash
cd smart-contract
sui move test
```

### **Interface Web**
```bash
cd frontend
# Ouvrir index.html dans différents navigateurs
# Tester avec différentes tailles d'écran
```

## 📈 **Métriques & Analytics**

Le jeu émet des événements trackables:
- `GameStarted`: Nouveau jeu créé
- `LevelCompleted`: Niveau terminé
- `BossDefeated`: Boss vaincu
- `HeroUpgraded`: Amélioration achetée
- `GameEnded`: Fin de partie avec gains/pertes

## 🤝 **Contribution**

Consultez [CONTRIBUTING.md](CONTRIBUTING.md) pour:
- 🐛 Signaler des bugs
- 💡 Proposer des améliorations
- 🔧 Contribuer au code
- 📚 Améliorer la documentation

## 📜 **Licence**

Ce projet est sous licence MIT. Voir [LICENSE](LICENSE) pour plus de détails.

## 🔗 **Liens Utiles**

- **📖 [Documentation Sui](https://docs.sui.io/)**
- **🏗️ [Move Language](https://move-language.github.io/)**
- **💬 [Discord Sui](https://discord.gg/sui)**
- **🐦 [Twitter @SuiNetwork](https://twitter.com/SuiNetwork)**

## ⚠️ **Avertissements**

- **Risque financier**: Ce jeu implique des paris. Ne misez que ce que vous pouvez vous permettre de perdre
- **Smart contract**: Vérifiez toujours les adresses des contrats avant d'interagir
- **Version Beta**: Le jeu est en développement actif

## 📞 **Support**

- 🐛 **Bugs**: [GitHub Issues](https://github.com/VoxJusticia/tower-defense-sui/issues)
- 💬 **Questions**: [GitHub Discussions](https://github.com/VoxJusticia/tower-defense-sui/discussions)
- 📧 **Contact**: nolan.bouvet@epfl.ch

---

<div align="center">

**🏰 Prêt à défendre votre tour et gagner des SUI? 🏰**

[🎮 **JOUER MAINTENANT**](https://VoxJusticia.github.io/tower-defense-sui) | [📖 **DOCUMENTATION**](./docs/) | [🛠️ **CONTRIBUER**](./CONTRIBUTING.md)

*Fait avec ❤️ sur la blockchain Sui*

</div>
