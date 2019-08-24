

.PHONY: run clean build clean-run stop

run:
	docker-compose up

clean:
	-docker container rm etcd
	-docker volume rm etcd-data

build:
	make -C etcd-docker build

clean-run: stop clean build run

stop:
	-docker-compose down

