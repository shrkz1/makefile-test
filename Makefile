SHELL=/bin/bash

CURRENT_BRANCH=$(shell git branch | grep '*' | tr -d '* ')

ALL: help
.PHONY: help install test need-version bump-version tag-version

help:
	@echo "Makefile"
	@echo "================"
	@echo ""
	@echo "target"
	@echo "  Description."
	@echo ""
	@echo "target2"
	@echo "  Description."

test: install
	vendor/bin/phpunit

# Utility target for checking required parameters
guard-%:
	@if [ "$($*)" = '' ]; then \
		echo "Missing required $* variable."; \
		exit 1; \
	fi;

# Download composer
composer.phar:
	curl -sS https://getcomposer.org/installer | php

# Install dependencies
install: composer.phar
	php composer.phar install

# Version bumping & tagging for CakePHP itself
# Update VERSION.txt to new version.
bump-version: guard-VERSION
	@echo "Update VERSION.txt to $(VERSION)"
	# Work around sed being bad.
	mv VERSION.txt VERSION.old
	cat VERSION.old | sed s'/^[0-9]\.[0-9]\.[0-9].*/$(VERSION)/' > VERSION.txt
	rm VERSION.old
	git add VERSION.txt
	git commit -m "Update version number to $(VERSION)"

# Tag a release
tag-release: guard-VERSION bump-version
	@echo "Tagging $(VERSION)"
	#git tag -s $(VERSION) -m "$(VERSION)"
	git tag $(VERSION) -m "$(VERSION)"
	git push $(REMOTE)
	git push $(REMOTE) --tags

###########
###########
###########

hey: one two
	# Outputs "hey", since this is the first target
	echo $@

	# Outputs all prerequisites newer than the target
	echo $?

	# Outputs all prerequisites
	echo $^

	touch hey

one:
	touch one

two:
	touch two

clean:
	rm -f hey one two
