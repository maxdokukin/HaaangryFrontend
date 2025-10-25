#!/usr/bin/env bash
set -euo pipefail

root="haaangry-frontend"

mkdir -p "$root"/Models
mkdir -p "$root"/Networking
mkdir -p "$root"/Stores
mkdir -p "$root"/Views/Overlays
mkdir -p "$root"/Views/Order
mkdir -p "$root"/Views/LLM
mkdir -p "$root"/Views/Recipes
mkdir -p "$root"/Views/Profile
mkdir -p "$root"/Utilities
mkdir -p "$root"/Resources/fixtures

touch "$root"/Models/Video.swift
touch "$root"/Models/Restaurant.swift
touch "$root"/Models/MenuItem.swift
touch "$root"/Models/OrderModels.swift
touch "$root"/Models/RecipeModels.swift

touch "$root"/Networking/Endpoint.swift
touch "$root"/Networking/APIClient.swift
touch "$root"/Networking/Fixtures.swift

touch "$root"/Stores/FeedStore.swift
touch "$root"/Stores/OrderStore.swift
touch "$root"/Stores/ProfileStore.swift

touch "$root"/Views/VideoFeedView.swift
touch "$root"/Views/VideoCardView.swift

touch "$root"/Views/Overlays/RightMetaOverlay.swift
touch "$root"/Views/Overlays/BottomActionsBar.swift

touch "$root"/Views/Order/OrderOptionsSheet.swift
touch "$root"/Views/Order/CartView.swift

touch "$root"/Views/LLM/ChatToOrderView.swift
touch "$root"/Views/LLM/VoiceToOrderView.swift

touch "$root"/Views/Recipes/RecipesView.swift
touch "$root"/Views/Profile/ProfileView.swift

touch "$root"/Utilities/SpeechRecognizer.swift

touch "$root"/Resources/fixtures/feed.json
touch "$root"/Resources/fixtures/order_options_v1.json
touch "$root"/Resources/fixtures/recipes_v1.json
touch "$root"/Resources/fixtures/profile.json

touch "$root"/BiteSwipeApp.swift

echo "Created ./$root"

