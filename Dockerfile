FROM golang:1.14

ENV GO111MODULE=on
ENV PORT=9000
WORKDIR /app/server
COPY go.mod .
COPY go.sum .
COPY main.go .

RUN go mod download
# COPY . .

RUN go build 
CMD ["./devops-techtask"]