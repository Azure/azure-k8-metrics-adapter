REGISTRY?=jsturtevant
IMAGE?=azure-k8-metrics-adapter
TEMP_DIR:=$(shell mktemp -d)
ARCH?=amd64
OUT_DIR?=./_output

VERSION?=latest
GOIMAGE=golang:1.10

.PHONY: all build test verify build-container

all: build
build-local: vendor
	CGO_ENABLED=0 GOARCH=$(ARCH) go build -a -tags netgo -o $(OUT_DIR)/$(ARCH)/adapter github.com/Azure/azure-k8s-metrics-adapter

build:
	docker build -t $(REGISTRY)/$(IMAGE)-$(ARCH):$(VERSION) .

save:
	docker save -o /caches/app.tar $(REGISTRY)/$(IMAGE)-$(ARCH):$(VERSION)

version:
	go get -u github.com/Clever/gitsem
	gitsem patch tag=true
	
push:
	@docker login -u $(DOCKER_USER) -p '$(DOCKER_PASS)'    
	docker push $(REGISTRY)/$(IMAGE)-$(ARCH):$(VERSION)

vendor: 
	dep ensure

test: vendor
	CGO_ENABLED=0 go test ./pkg/...

dev:
	skaffold dev

deploy:
	skaffold run




