IMAGE_NAME 	:=	catks/gitserver-http
SAMPLE_REPO	:=  ./examples/repositories/sample-repo
BUILD_VERSION 	:=  $(shell git describe --tags)

all: image

test:
	docker-compose build
	docker-compose run --rm gitclient sh test.sh
	docker-compose down

image:
	docker build -t $(IMAGE_NAME) .

release:
	verto tag up --${VERSION}

	docker tag $(IMAGE_NAME) $(IMAGE_NAME):$(BUILD_VERSION)

	docker push $(IMAGE_NAME):$(BUILD_VERSION)


example-no-init:
	docker-compose -f ./examples/docker-compose.no-init.yml up


example:
	docker-compose -f ./examples/docker-compose.yml up


.PHONY: image example example-no-init test release
