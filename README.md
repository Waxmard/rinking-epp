# TierNerd

A cross-platform mobile application that lets users create custom lists and rank items through an unbiased comparison system, presenting results in intuitive S-F tier rankings.

## Overview

This app solves the problem of arbitrary ratings by implementing a 1v1 comparison algorithm. Rather than asking users to assign subjective numerical scores to items, the app presents pairs of items and asks which is better. Through a series of binary choices, each item finds its proper place in the list and receives a numeric rating which is then converted to an intuitive tier ranking (S, A, B, C, D, F).

## Key Features

- Create custom lists on any topic
- Add items with descriptions and images
- Rank items through simple better/worse comparisons
- Eliminate arbitrary rating bias
- View results as both ordered lists and intuitive tier rankings (S-F)
- Understand at a glance which items are top-tier (S) vs lower tiers

## Technology

- **Frontend:** React Native with Expo (SDK 54)
- **Backend:** Python with FastAPI
- **Database:** PostgreSQL

## Getting Started

### Frontend
```bash
cd frontend
npm install --legacy-peer-deps
npx expo start                    # Scan QR with Expo Go app
# or
npm run ios                       # iOS Simulator
```

### Backend
```bash
cd fastapi
make dev-up                       # Start with Docker
```

See [frontend/README.md](frontend/README.md) and [fastapi/README.md](fastapi/README.md) for detailed setup instructions.

## Tier Ranking System

TierNerd uses a standardized tier ranking system common in gaming and competitive communities:

- **S Tier**: The absolute best items (exceptional)
- **A Tier**: Excellent items (above average)
- **B Tier**: Good items (slightly above average)
- **C Tier**: Average items (balanced)
- **D Tier**: Below average items
- **F Tier**: The lowest ranked items

While the underlying algorithm assigns numeric values, users interact with this intuitive tier system for easier comprehension and comparison.

## Project Status

Currently in initial development phase.
