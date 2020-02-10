export DOCKER_FLUENTD_TAG=v1.8-debian-1
export MY_NETWORK=my-network

fluentd: shared-network init
	docker run \
    --rm \
    --interactive \
    --tty \
    --publish 24424:24424 \
    --mount type=bind,source=${PWD}/fluentd/fluent.conf,target=/fluentd/etc/fluent.conf \
    --mount type=bind,source=${PWD}/tmp/my-out,target=/fluentd/my-out \
    --mount type=bind,source=${PWD}/tmp/my-buffer,target=/fluentd/my-buffer \
    --name fluentd \
    --net ${MY_NETWORK} \
    --env TZ=Asia/Tokyo \
    fluentd:${DOCKER_FLUENTD_TAG}

logger: shared-network
	docker run \
    --rm \
    --interactive \
    --tty \
    --name logger \
    --mount type=bind,source=${PWD}/logger/logger.sh,target=/fluentd/logger.sh \
    --net ${MY_NETWORK} \
    --env TZ=Asia/Tokyo \
    --workdir /fluentd \
    fluentd:${DOCKER_FLUENTD_TAG} \
    bash ./logger.sh

shared-network:
	docker network ls | grep ${MY_NETWORK} || docker network create ${MY_NETWORK}

clean:
	docker container prune
	docker network prune
	rm -rf ./tmp

init:
	rm -rf ./tmp
	mkdir -p ./tmp/my-out
	mkdir -p ./tmp/my-buffer
	chmod o+w ./tmp/my-out
	chmod o+w ./tmp/my-buffer

tree:
	watch -n 1 tree ./tmp
