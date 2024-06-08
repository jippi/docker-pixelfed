docs-server:
	docker build --pull -t docker-pixelfed-docs -f Dockerfile.docs .
	docker run --rm -it -p 8000:8000 -v ${PWD}:/docs docker-pixelfed-docs serve
