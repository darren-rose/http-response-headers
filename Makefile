build:
	@go build -o out/http-response-headers .
	@echo "build available in ./out/http-response-headers"

docker-build:
	@docker build -t darren-rose/http-response-headers .
	@echo "build docker image"

docker-run:
	@docker run --rm -p 8080:8080 darren-rose/http-response-headers
