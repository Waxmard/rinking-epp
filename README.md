# TierNerd

A cross-platform mobile application that lets users create custom lists and rank items through an unbiased comparison system, presenting results in intuitive S-F tier rankings.

## Overview

This app solves the problem of arbitrary ratings by implementing a 1v1 comparison algorithm. Rather than asking users to assign subjective numerical scores to items, the app presents pairs of items and asks which is better. Through a series of binary choices, each item finds its proper place in the list and receives a numeric rating which is then converted to an intuitive tier ranking (S, A, B, C, D, E, F).

## Key Features

- Create custom lists on any topic
- Add items with descriptions and images
- Rank items through simple better/worse comparisons
- Eliminate arbitrary rating bias
- View results as both ordered lists and intuitive tier rankings (S-F)
- Understand at a glance which items are top-tier (S) vs lower tiers

## Technology

Built with Flutter for the frontend and Python (FastAPI) for the backend. Uses PostgreSQL for database storage.

## Tier Ranking System

TierNerd uses a standardized tier ranking system common in gaming and competitive communities:

- **S Tier**: The absolute best items (exceptional)
- **A Tier**: Excellent items (above average)
- **B Tier**: Good items (slightly above average)
- **C Tier**: Average items (balanced)
- **D Tier**: Below average items
- **E Tier**: Poor items
- **F Tier**: The lowest ranked items

While the underlying algorithm assigns numeric values, users interact with this intuitive tier system for easier comprehension and comparison.

## Project Status

Currently in initial development phase.
