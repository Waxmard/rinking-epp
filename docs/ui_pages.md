# TierNerd UI Pages Documentation

This document outlines the simplified UI pages and user flows for the TierNerd application, focusing on list management functionality.

## Overview

TierNerd allows users to:
- Create customizable lists
- Add items to lists
- Compare and rank items
- Organize items into tiers (S through F)
- View their tiered rankings

## Pages

### 1. Home Screen

The home screen serves as the central hub for users to access their lists.

**Features:**
- Most recent list display (if any exists)
- Create new list button (prominent call-to-action)
- Access to all user lists
- User profile access via persistent avatar icon

**UI Elements:**
- User avatar in corner for accessing profile/settings
- Most recent list card showing:
  - List title
  - Item count
  - Last modified date
- List of other user lists in scrollable format
- Prominent "Create New List" button
- Quick action buttons on each list card (edit, delete)

### 2. List Detail Page

Detailed view of a single list showing all items and their rankings.

**Features:**
- List metadata (title, description, creation date)
- Items organized by tier (S through F)
- Unranked items section
- Add new items directly within the list
- Edit list details
- Inline item comparison functionality

**UI Elements:**
- List header with metadata
- Tier sections (collapsible)
- Item cards within each tier
- Draggable items for manual tier adjustment
- Inline "Add Item" field (text input with add button)
- Edit list details button
- Comparison overlay that appears when adding new items
- Quick edit options on item cards

### 3. Create/Edit List Page

Interface for creating a new list or editing an existing one.

**Features:**
- Set list title and description
- Configure basic list settings
- Add initial items during creation (optional)

**UI Elements:**
- Form fields for list details
- Privacy toggle
- Initial items section (optional)
- Save/Cancel buttons

## User Flows

### Creating a New List

1. User taps "Create New List" button on home screen
2. User enters list title and description
3. User adds initial items (optional)
4. User saves list
5. System navigates to list detail page

### Adding Items to Existing List

1. User selects a list from home screen
2. User views list detail page
3. User enters new item name in the inline "Add Item" input field
4. User submits the item
5. Comparison overlay immediately appears:
   - User selects which item is preferred in each comparison
   - System automatically ranks the new item based on comparisons
   - Overlay dismisses once ranking is complete
   - Item appears in its proper tier without page navigation

### Managing User Profile

1. User taps avatar icon from any screen
2. User accesses profile information and settings
3. User makes desired changes
4. User returns to previous screen

## Design Guidelines

- Use consistent tier colors:
  - S Tier: Gold/Yellow (#FFD700)
  - A Tier: Green (#4CAF50)
  - B Tier: Blue (#2196F3)
  - C Tier: Purple (#9C27B0)
  - D Tier: Orange (#FF9800)
  - F Tier: Gray (#9E9E9E)
- Implement responsive design for various screen sizes
- Prioritize smooth animations for comparison and ranking operations

## Future Enhancements

- Support both light and dark modes
- Sharing functionality
- Templates for common list types
- Advanced ranking algorithms
- Custom tier labels and colors
- Import items from external sources
