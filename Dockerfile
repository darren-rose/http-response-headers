# syntax=docker/dockerfile:1

# STAGE 1: building the executable
FROM golang:1.19-alpine AS build

# git required for go mod
RUN apk add --no-cache git

# certs
RUN apk --no-cache add ca-certificates

# add a user here because addgroup and adduser are not available in scratch
RUN addgroup -S myapp && adduser -S -u 10000 -g myapp myapp

WORKDIR /app
COPY ./go.mod ./go.sum ./
RUN go mod download

# Import code
COPY ./ ./

RUN CGO_ENABLED=0 go build -o http-response-headers -ldflags="-w -s"

# STAGE 2: build the container to run
FROM scratch AS final

# copy compiled app
COPY --from=build /app/http-response-headers /app/http-response-headers

# copy ca certs
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# copy users from builder which contains myapp user
COPY --from=0 /etc/passwd /etc/passwd

USER myapp

ENV GIN_MODE=release
ENTRYPOINT ["/app/http-response-headers"]