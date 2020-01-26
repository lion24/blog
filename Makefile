.PHONY: build pre-build post-build bootstrap cibuild deploy

NAME=$(shell basename $(CURDIR))
IMAGE=$(NAME)
IMAGE_BUILDER=$(NAME)-builder
IMAGE_PROD=$(NAME)
cwd := $(shell pwd)
UID := $(shell id -u)
GID := $(shell id -g)
USE_DOCKER := 0


bootstrap:
ifeq ($(USE_DOCKER), 1)
	docker build -f docker/$(IMAGE_BUILDER).Dockerfile -t $(IMAGE_BUILDER) .
else
	./script/bootstrap
endif

.env: .SHELLFLAGS = -c eval
.env: SHELL = bash -c 'eval "$${@//\\\\/}"'

.env:
ifeq ($(USE_DOCKER), 1)
	cat <<EOF > $@ \
	JEKYLL_UID=$(UID)\
	JEKYLL_GID=$(GID)\
	EOF
endif

cibuild: .env build
ifeq ($(USE_DOCKER), 1)
	docker run --rm -it \
		--env-file .env \
		-v $(cwd):/srv/jekyll \
		$(IMAGE_BUILDER) bash -c "./script/cibuild"
else
	./script/cibuild
endif

blog:
	docker build -f docker/$(IMAGE_PROD).Dockerfile -t $(IMAGE_PROD) .

release:
