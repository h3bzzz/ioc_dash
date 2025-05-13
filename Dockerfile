FROM golang:1.24.2-alpine AS builder
RUN apk add --no-cache git

RUN go install github.com/pressly/goose/v3/cmd/goose@latest \
  && go install github.com/cosmtrek/air@latest

WORKDIR /app
COPY go.mod go.sum ./
RUNgo mod download

COPY . .
RUN go build -o /usr/local/bin/server cmd/server/main.go

FROM alpine:latest
RUN apk add --no-cache ca-certificates postgresql-client

COPY --from=builder /go/bin/goose         /usr/local/bin/goose
COPY --from=builder /go/bin/air           /usr/local/bin/air 
COPY --from=builder /usr/local/bin/server /usr/local/bin/server

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /app
ENTRYPOINT ["entrypoint.sh"]
