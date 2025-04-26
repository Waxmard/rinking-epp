# Ranking App

A cross-platform mobile application that lets users create custom lists and rank items through an unbiased comparison system.

## Overview

This app solves the problem of arbitrary ratings by implementing a 1v1 comparison algorithm. Rather than asking users to assign subjective numerical scores to items, the app presents pairs of items and asks which is better. Through a series of binary choices, each item finds its proper place in the list and receives a rating between 0.1 and 10.0 based on its position.

## Key Features

- Create custom lists on any topic
- Add items with descriptions and images
- Rank items through simple better/worse comparisons
- Eliminate arbitrary rating bias
- View results as both ordered lists and normalized ratings

## Technology

Built with Flutter for the frontend and Python (FastAPI) for the backend. Uses PostgreSQL for database storage.

## Project Status

Currently in initial development phase.
