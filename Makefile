# Ruby on Rails Makefile
# Usage: make <target>

# ANSI Color Codes
COLOR_RESET=\033[0m
COLOR_BOLD=\033[1m
COLOR_RED=\033[31m
COLOR_GREEN=\033[32m
COLOR_YELLOW=\033[33m
COLOR_BLUE=\033[34m
COLOR_MAGENTA=\033[35m
COLOR_CYAN=\033[36m

# Emoji Icons
ICON_CHECK=✅
ICON_ERROR=❌
ICON_WARN=⚠️
ICON_INFO=ℹ️
ICON_ROCKET=🚀
ICON_DATABASE=🗄️
ICON_SYNC=🔄
ICON_SERVER=🖥️
ICON_TEST=🧪

.PHONY: help setup dev test db-sync db-migrate db-rollback db-seed

# Default target
help:
	@echo "${COLOR_BOLD}${COLOR_CYAN}${ICON_ROCKET} Ruby on Rails Makefile${COLOR_RESET}"
	@echo ""
	@echo "${COLOR_BOLD}${COLOR_MAGENTA}Quick start:${COLOR_RESET}"
	@echo "  ${COLOR_GREEN}setup${COLOR_RESET}    # First time setup"
	@echo "  ${COLOR_GREEN}dev${COLOR_RESET}      # Start development server"
	@echo "  ${COLOR_GREEN}db-sync${COLOR_RESET}  # Sync production database to local"
	@echo ""
	@echo "${COLOR_BOLD}${COLOR_BLUE}Available targets:${COLOR_RESET}"
	@echo "  ${COLOR_GREEN}help${COLOR_RESET}       - Show this help"
	@echo "  ${COLOR_GREEN}setup${COLOR_RESET}      - Setup project (bundle install, db:create, db:migrate, db:seed)"
	@echo "  ${COLOR_GREEN}dev${COLOR_RESET}        - Start development server"
	@echo "  ${COLOR_GREEN}test${COLOR_RESET}       - Run tests"
	@echo ""
	@echo "${COLOR_BOLD}${COLOR_BLUE}Database:${COLOR_RESET}"
	@echo "  ${COLOR_GREEN}db-sync${COLOR_RESET}    - Sync database from production"
	@echo "  ${COLOR_GREEN}db-migrate${COLOR_RESET} - Run database migrations"
	@echo "  ${COLOR_GREEN}db-rollback${COLOR_RESET} - Rollback last database migration"
	@echo "  ${COLOR_GREEN}db-seed${COLOR_RESET}    - Run database seeds"

# Project setup
setup:
	@echo "${COLOR_BOLD}${COLOR_CYAN}${ICON_ROCKET} Setting up project...${COLOR_RESET}"
	@bin/setup
	@echo "${COLOR_GREEN}${ICON_CHECK} Setup completed!${COLOR_RESET}"

# Development server
dev:
	@echo "${COLOR_BOLD}${COLOR_CYAN}${ICON_SERVER} Starting development server...${COLOR_RESET}"
	@bin/dev

# Run tests
test:
	@echo "${COLOR_BOLD}${COLOR_CYAN}${ICON_TEST} Running tests...${COLOR_RESET}"
	@bin/rails test

# Database migrations
db-migrate:
	@echo "${COLOR_BOLD}${COLOR_CYAN}${ICON_DATABASE} Running database migrations...${COLOR_RESET}"
	@bin/rails db:migrate
	@echo "${COLOR_GREEN}${ICON_CHECK} Migrations completed!${COLOR_RESET}"

db-rollback:
	@echo "${COLOR_BOLD}${COLOR_CYAN}${ICON_DATABASE} Rolling back last migration...${COLOR_RESET}"
	@bin/rails db:rollback
	@echo "${COLOR_GREEN}${ICON_CHECK} Rollback completed!${COLOR_RESET}"

db-seed:
	@echo "${COLOR_BOLD}${COLOR_CYAN}${ICON_DATABASE} Running database seeds...${COLOR_RESET}"
	@bin/rails db:seed
	@echo "${COLOR_GREEN}${ICON_CHECK} Seeds completed!${COLOR_RESET}"

# Database sync from production
# Requires environment variables (set in .env):
#   PRODUCTION_DB_HOST, PRODUCTION_DB_PORT, PRODUCTION_DB_NAME, 
#   PRODUCTION_DB_USER, PRODUCTION_DB_PASSWORD
db-sync:
	@echo "${COLOR_BOLD}${COLOR_CYAN}${ICON_SYNC} Syncing database from production...${COLOR_RESET}"
	@chmod +x bin/sync-db
	@bin/sync-db