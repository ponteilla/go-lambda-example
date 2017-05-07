GOPATH  ?= $(HOME)/go

WORKDIR = $(CURDIR:$(GOPATH)%=/go%)
ifeq ($(WORKDIR),$(CURDIR))
	WORKDIR = /tmp
endif

CMDS = $(wildcard lambda/*)

docker:
	@docker run --rm                                                             \
	  -v $(GOPATH):/go                                                           \
	  -v $(CURDIR):/tmp                                                          \
	  -w $(WORKDIR)                                                              \
	  eawsy/aws-lambda-go-shim:latest make all

deps:
	@go get -u github.com/FiloSottile/gvt
	@gvt restore

tests:
	@go test -v $(shell go list ./... | grep -v /vendor/)

all: $(CMDS)

$(CMDS):
	@go build -buildmode=plugin -ldflags='-w -s' -o $@/handler.so ./$@/...
	@mkdir -p /package/handler
	@cp $@/handler.so /package/handler.so
	@cp /shim/__init__.pyc /package/handler/__init__.pyc
	@cp /shim/proxy.pyc /package/handler/proxy.pyc
	@cp /shim/runtime.so /package/handler/runtime.so
	@pushd /package; zip -qr handler.zip *; popd
	@mv /package/handler.zip $@/handler.zip
	@chown $(shell stat -c '%u:%g' .) $@/handler.so $@/handler.zip

.PHONY: docker deps tests all $(CMDS)
