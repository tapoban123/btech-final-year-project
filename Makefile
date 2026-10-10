# ==============================================================================
# OmniDoc AI — Developer Makefile
# Works on macOS, Linux, and Windows (with make installed)
# ==============================================================================

.DEFAULT_GOAL := help
.PHONY: help sync push pull status commit save backend-dev backend-install mobile-dev mobile-get clean

# Default commit message if none is passed via msg="..."
msg ?= update

# ------------------------------------------------------------------------------
# 1. Help / Documentation
# ------------------------------------------------------------------------------
help:
	@echo "====================================================================="
	@echo "OmniDoc AI — Quick Command Shortcuts"
	@echo "====================================================================="
	@echo "Git Shortcuts:"
	@echo "  make sync             - Pull from origin main and push local commits"
	@echo "  make push             - Push local commits to origin main"
	@echo "  make pull             - Pull latest changes from origin main"
	@echo "  make status           - Show current git status"
	@echo "  make commit msg=\"...\" - Stage all changes and commit with message"
	@echo "  make save msg=\"...\"   - Stage, commit, and push to origin main"
	@echo ""
	@echo "Backend Shortcuts (FastAPI):"
	@echo "  make backend-install  - Install backend dependencies"
	@echo "  make backend-dev      - Run FastAPI dev server with auto-reload"
	@echo ""
	@echo "Frontend Shortcuts (Flutter):"
	@echo "  make mobile-get       - Install Flutter dependencies"
	@echo "  make mobile-dev       - Run Flutter app on connected device/emulator"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean            - Remove Python cache files (__pycache__, *.pyc)"
	@echo "====================================================================="

# ------------------------------------------------------------------------------
# 2. Git Automation
# ------------------------------------------------------------------------------
sync:
	git pull origin main
	git push origin main

push:
	git push origin main

pull:
	git pull origin main

status:
	git status

commit:
	git add -A
	git commit -m "$(msg)"

save:
	git add -A
	git commit -m "$(msg)"
	git push origin main

# ------------------------------------------------------------------------------
# 3. Backend (Python / FastAPI)
# ------------------------------------------------------------------------------
backend-install:
	pip install -r backend/requirements.txt

backend-dev:
	uvicorn app.main:app --reload --app-dir backend

# ------------------------------------------------------------------------------
# 4. Frontend (Flutter)
# ------------------------------------------------------------------------------
mobile-get:
	cd mobile && flutter pub get

mobile-dev:
	cd mobile && flutter run

# ------------------------------------------------------------------------------
# 5. Maintenance (Cross-Platform Python Clean)
# ------------------------------------------------------------------------------
clean:
	python -c "import pathlib, shutil; [shutil.rmtree(p) for p in pathlib.Path('.').rglob('__pycache__')]; [p.unlink() for p in pathlib.Path('.').rglob('*.py[co]')]"
	@echo "Cleaned Python cache files."
