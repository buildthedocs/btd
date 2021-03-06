FROM golang:alpine

ENV CGO_ENABLED 0

RUN apk --no-cache -U upgrade \
 && apk --no-cache add ca-certificates git curl dos2unix zip make \
 && curl -sL https://git.io/goreleaser -o /go/bin/goreleaser \
 && chmod +x /go/bin/goreleaser \
 && curl -fsSL https://download.docker.com/linux/static/edge/x86_64/docker-18.06.3-ce.tgz | tar xvz --strip-components=1 docker/docker -C /go/bin \
 && chmod +x /go/bin/docker \
 && curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s -- -b $(go env GOPATH)/bin "latest"
