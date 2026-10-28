PACKAGE_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
KPACKAGE_TOOL ?= kpackagetool6

.PHONY: install uninstall

install:
	@if $(KPACKAGE_TOOL) -t KWin/WindowSwitcher -s monitor_task_switcher >/dev/null 2>&1; then \
		$(KPACKAGE_TOOL) -t KWin/WindowSwitcher -u "$(PACKAGE_DIR)"; \
	else \
		$(KPACKAGE_TOOL) -t KWin/WindowSwitcher -i "$(PACKAGE_DIR)"; \
	fi
	@printf '%s\n' 'Para carregar mudancas QML, encerre a sessao KDE e entre novamente.'

uninstall:
	$(KPACKAGE_TOOL) -t KWin/WindowSwitcher -r monitor_task_switcher