## Setup
SHELL := /bin/bash
SRC = $(shell find . -type f -name '*.go' -not -path "./vendor/*")

setup:
	go get golang.org/x/crypto/ocsp
	go get github.com/golang/lint/golint
	go get github.com/Songmu/make2help/cmd/make2help
	go get honnef.co/go/tools/cmd/megacheck

## Install dependencies
deps: setup
	dep ensure

## Update dependencies
update: setup
	dep ensure -update

## Show help
help:
	@make2help $(MAKEFILE_LIST)

# Format source codes (internally used)
cfmt: setup
	gofmt -l -w $(SRC)

# Lint (internally used)
clint: setup
	megacheck
	for pkg in $$(go list ./... | grep -v /vendor/); do \
		echo "Verifying $$pkg"; \
		go vet $$pkg; \
		golint -set_exit_status $$pkg || exit $$?; \
	done

# Install (internally used)
cinstall:
	export GOBIN=$$GOPATH/bin; \
	go install -tags=sfdebug $(CMD_TARGET).go

# Run (internally used)
crun: install
	$(CMD_TARGET)

.PHONY: setup help cfmt clint cinstall crun
