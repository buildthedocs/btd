# Authors:
#   Unai Martinez-Corral
#
# Copyright 2017-2023 Unai Martinez-Corral <unai.martinezcorral@ehu.eus>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

FROM golang:alpine

ENV CGO_ENABLED 0

RUN apk --no-cache -U upgrade \
 && apk --no-cache add ca-certificates git curl dos2unix zip make \
 && curl -sL https://git.io/goreleaser -o /go/bin/goreleaser \
 && chmod +x /go/bin/goreleaser \
 && curl -fsSL https://download.docker.com/linux/static/edge/x86_64/docker-18.06.3-ce.tgz | tar xvz --strip-components=1 docker/docker -C /go/bin \
 && chmod +x /go/bin/docker \
 && curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s -- -b $(go env GOPATH)/bin "latest"
