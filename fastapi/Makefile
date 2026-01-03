# Makefile for TierNerd FastAPI Backend

# Variables
IMAGE_NAME := tiernerd-backend
TAG := latest

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  build-local    - Build for current platform only (fast)"
	@echo "  build-multi    - Build for multiple platforms (amd64 + arm64)"
	@echo "  build-compose  - Build using docker-compose"
	@echo "  run            - Run the container locally"
	@echo "  stop           - Stop the container"
	@echo "  logs           - View container logs"
	@echo "  clean          - Remove containers and images"
	@echo "  push           - Push multi-platform image to registry"
	@echo "  test-build     - Test build without caching"

# Build for current platform only (faster for local development)
.PHONY: build-local
build-local:
	@if docker buildx version > /dev/null 2>&1; then \
		echo "Using buildx for optimized build..."; \
		docker buildx bake local; \
	else \
		echo "Using regular docker build..."; \
		docker build -t $(IMAGE_NAME):local .; \
	fi

# Build for multiple platforms (for sharing with teammates)
.PHONY: build-multi  
build-multi:
	@if docker buildx version > /dev/null 2>&1; then \
		echo "Using buildx for multi-platform build..."; \
		docker buildx bake backend; \
	else \
		echo "Buildx not available, building for current platform only..."; \
		docker build -t $(IMAGE_NAME):latest .; \
	fi

# Build using docker-compose
.PHONY: build-compose
build-compose:
	COMPOSE_BAKE=true docker-compose build

# Run the application
.PHONY: run
run:
	docker-compose up -d

# Stop the application
.PHONY: stop
stop:
	docker-compose down

# View logs
.PHONY: logs
logs:
	docker-compose logs -f backend

# Clean up containers and images
.PHONY: clean
clean:
	docker-compose down -v --remove-orphans
	docker image rm $(IMAGE_NAME):latest $(IMAGE_NAME):local 2>/dev/null || true
	docker system prune -f

# Push to registry (requires REGISTRY variable)
.PHONY: push
push:
	@if [ -z "$(REGISTRY)" ]; then \
		echo "Error: REGISTRY variable not set. Use: make push REGISTRY=your-registry.com/"; \
		exit 1; \
	fi
	REGISTRY=$(REGISTRY) docker buildx bake multi --push

# Test build without caching
.PHONY: test-build
test-build:
	docker buildx bake backend --no-cache

# Setup buildx builder (run once)
.PHONY: setup-buildx
setup-buildx:
	docker buildx create --name multiplatform --driver docker-container --use
	docker buildx inspect --bootstrap

# Health check
.PHONY: health
health:
	curl -f http://localhost:8000/health || echo "Service not healthy"

# Dev commands
.PHONY: dev-up dev-down dev-logs restart fresh quick-restart
dev-up:
	make build-local && make run

dev-down:
	make stop

dev-logs:
	make logs

# Convenience commands
restart: build-local stop run
	@echo "Container rebuilt and restarted"

fresh: build-local stop run
	@echo "Container rebuilt and restarted, showing logs..."
	make logs

quick-restart: stop run
	@echo "Container restarted (no rebuild)"