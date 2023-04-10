#-------------------------------------------------------------------------------
# Global stuff.

SHELL:=bash
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(dir $(mkfile_path))

# Determine the operating system and CPU arch.
OS=$(shell uname -o | tr '[:upper:]' '[:lower:]')
ARCH=$(shell ./arch.py --x86 amd64 --arm arm64 $(shell uname -m))

# Determine which version of `echo` to use. Use version from coreutils if available.
ECHOCHECK_HOMEBREW_AMD64 := $(shell command -v /usr/local/opt/coreutils/libexec/gnubin/echo 2> /dev/null)
ECHOCHECK_HOMEBREW_ARM64 := $(shell command -v /opt/homebrew/opt/coreutils/libexec/gnubin/echo 2> /dev/null)

ifdef ECHOCHECK_HOMEBREW_AMD64
	ECHO=/usr/local/opt/coreutils/libexec/gnubin/echo -e
else ifdef ECHOCHECK_HOMEBREW_ARM64
	ECHO=/opt/homebrew/opt/coreutils/libexec/gnubin/echo -e
else ifeq ($(findstring linux,$(OS)), linux)
	ECHO=echo -e
else
	ECHO=echo
endif

#-------------------------------------------------------------------------------
# Running `make` will show the list of subcommands that will run.

all: help

.PHONY: help
## help: [help]* Prints this help message.
help:
	@ $(ECHO) "Usage:"
	@ $(ECHO) ""
	@ sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /' | \
		while IFS= read -r line; do \
			if [[ "$$line" == *"]*"* ]]; then \
				$(ECHO) "\033[1;33m$$line\033[0m"; \
			else \
				$(ECHO) "$$line"; \
			fi; \
		done

#-------------------------------------------------------------------------------
# Linting

.PHONY: perms
## perms: [lint] Fixes the file permissions.
perms:
	@ $(ECHO) " "
	@ $(ECHO) "\033[1;33m=====> Setting standard file permissions...\033[0m"
	find . -type d -not -path "./.git/*" -not -path "./.venv/*" | xargs chmod 0755
	find . -type f -not -path "./.git/*" -not -path "./.venv/*" | xargs chmod 0644
	find . -type f -name "*.sh" | xargs chmod +x
	find . -type f -name "*.py" | xargs chmod +x

.PHONY: lint
## lint: [lint]* Runs ALL linting/validation tasks. Also runs on commit.
lint: perms
	@ $(ECHO) " "
	@ $(ECHO) "\033[1;33m=====> Running pre-commit...\033[0m"
	pre-commit run --all-files

# https://stylelint.io

#-------------------------------------------------------------------------------
# Build and Serve

.PHONY:
## build: [build]* Perform a build of the website.
build:
	@ $(ECHO) " "
	@ $(ECHO) "\033[1;33m=====> Building site...\033[0m"
	mkdocs build

.PHONY: serve
## serve: [build]* Perform a development build of the website, and run a local web server.
serve:
	@ $(ECHO) " "
	@ $(ECHO) "\033[1;33m=====> Run Python development server...\033[0m"
	python -m http.server 8000 --directory ./site/ --protocol HTTP/1.1
