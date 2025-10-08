# 🔬 Scientific Research Peer Review Smart Contract

A decentralized platform for scientific paper peer reviews and funding on Stacks blockchain.

## 🎯 Features

- 📝 Publish research papers as on-chain entries
- ✅ Verified researcher system
- ⭐ Peer review submission with scoring
- 💰 Direct research funding mechanism
- 📊 Transparent review scoring

## 🚀 Usage

### For Administrators
1. Verify researchers using `verify-researcher`
2. Manage admin rights with `set-admin`

### For Researchers
1. Publish papers using `publish-paper`
2. Submit reviews using `submit-review`
3. View paper details with `get-paper-details`

### For Institutions
1. Fund research using `fund-research`
2. Check researcher verification status with `is-verified-researcher`

## 📈 Scoring System
- Scores range from 0-100
- Final score is average of all reviews
- View scores using `get-paper-score`

## ⚡ Quick Start
Deploy using Clarinet:
```bash
clarinet contract deploy
```

## 🔒 Security
- Only verified researchers can publish and review
- One review per paper per researcher
- Transparent funding tracking
```

Git commit message:
```
feat: Implement scientific research peer review smart contract MVP
```

PR Title:
```
✨ Add Scientific Research Peer Review Smart Contract
```

PR Description:
```
This PR introduces a new smart contract for decentralized scientific research peer review and funding.

Key additions:
- Research paper publication system
- Verified researcher management
- Peer review submission with scoring
- Direct funding mechanism
- Read-only functions for transparency

The implementation focuses on core functionality while maintaining security and simplicity.