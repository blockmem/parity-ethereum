#!/bin/sh

set -e # fail on any error

VERSION=$(cat ./tools/VERSION)
echo "Parity Ethereum version = ${VERSION}"

test "$Docker_Hub_User_Parity" -a "$Docker_Hub_Pass_Parity" \
    || ( echo "no docker credentials provided"; exit 1 )
docker login -u "$Docker_Hub_User_Parity" -p "$Docker_Hub_Pass_Parity"
echo "__________Docker info__________"
docker info

# we stopped pushing nightlies to dockerhub, will push to own registry prb.
case "${SCHEDULE_TAG:-${CI_COMMIT_REF_NAME}}" in
    "$SCHEDULE_TAG")
        echo "Docker TAG - 'parity/ethereum:${SCHEDULE_TAG}'";
        docker build --no-cache \
            --build-arg VCS_REF="${CI_COMMIT_SHA}" \
            --build-arg BUILD_DATE="$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
            --tag "parity/ethereum:${SCHEDULE_TAG}" \
            --file tools/ethereum.Dockerfile .;
        docker push "parity/ethereum:${SCHEDULE_TAG}";

        echo "Docker TAG - 'parity/parity:${SCHEDULE_TAG}'";
        docker build --no-cache \
            --build-arg FROM_VERSION="${SCHEDULE_TAG}" \
            --build-arg VCS_REF="${CI_COMMIT_SHA}" \
            --build-arg BUILD_DATE="$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
            --tag "parity/parity:${SCHEDULE_TAG}" \
            --file tools/parity.Dockerfile .;
        docker push "parity/parity:${SCHEDULE_TAG}";;
    "beta")
        echo "Docker TAGs - 'parity/ethereum:beta', 'parity/ethereum:latest', \
            'parity/ethereum:${VERSION}-${CI_COMMIT_REF_NAME}'";
        docker build --no-cache \
            --build-arg VCS_REF="${CI_COMMIT_SHA}" \
            --build-arg BUILD_DATE="$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
            --tag "parity/ethereum:beta" \
            --tag "parity/ethereum:latest" \
            --tag "parity/ethereum:${VERSION}-${CI_COMMIT_REF_NAME}" \
            --file tools/ethereum.Dockerfile .;
        docker push "parity/ethereum:beta";
        docker push "parity/ethereum:latest";
        docker push "parity/ethereum:${VERSION}-${CI_COMMIT_REF_NAME}";

        echo "Docker TAGs - 'parity/parity:beta', 'parity/parity:latest', \
            'parity/parity:${VERSION}-${CI_COMMIT_REF_NAME}'";
        docker build --no-cache \
            --build-arg FROM_VERSION="${VERSION}-${CI_COMMIT_REF_NAME}" \
            --build-arg VCS_REF="${CI_COMMIT_SHA}" \
            --build-arg BUILD_DATE="$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
            --tag "parity/parity:beta" \
            --tag "parity/parity:latest" \
            --tag "parity/parity:${VERSION}-${CI_COMMIT_REF_NAME}" \
            --file tools/parity.Dockerfile .;
        docker push "parity/parity:beta";
        docker push "parity/parity:latest";
        docker push "parity/parity:${VERSION}-${CI_COMMIT_REF_NAME}";;
    "stable")
        echo "Docker TAGs - 'parity/ethereum:${VERSION}-${CI_COMMIT_REF_NAME}', 'parity/ethereum:stable'";
        docker build --no-cache \
            --build-arg VCS_REF="${CI_COMMIT_SHA}" \
            --build-arg BUILD_DATE="$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
            --tag "parity/ethereum:${VERSION}-${CI_COMMIT_REF_NAME}" \
            --tag "parity/ethereum:stable" \
            --file tools/ethereum.Dockerfile .;
        docker push "parity/ethereum:${VERSION}-${CI_COMMIT_REF_NAME}";
        docker push "parity/ethereum:stable";

        echo "Docker TAGs - 'parity/parity:${VERSION}-${CI_COMMIT_REF_NAME}', 'parity/parity:stable'";
        docker build --no-cache \
            --build-arg FROM_VERSION="${VERSION}-${CI_COMMIT_REF_NAME}" \
            --build-arg VCS_REF="${CI_COMMIT_SHA}" \
            --build-arg BUILD_DATE="$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
            --tag "parity/parity:${VERSION}-${CI_COMMIT_REF_NAME}" \
            --tag "parity/parity:stable" \
            --file tools/parity.Dockerfile .;
        docker push "parity/parity:${VERSION}-${CI_COMMIT_REF_NAME}";
        docker push "parity/parity:stable";;
    *)
        echo "Docker TAG - 'parity/ethereum:${VERSION}-${CI_COMMIT_REF_NAME}'"
        docker build --no-cache \
            --build-arg VCS_REF="${CI_COMMIT_SHA}" \
            --build-arg BUILD_DATE="$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
            --tag "parity/ethereum:${VERSION}-${CI_COMMIT_REF_NAME}" \
            --file tools/ethereum.Dockerfile .;
        docker push "parity/ethereum:${VERSION}-${CI_COMMIT_REF_NAME}";

        echo "Docker TAG - 'parity/parity:${VERSION}-${CI_COMMIT_REF_NAME}'"
        docker build --no-cache \
            --build-arg FROM_VERSION="${VERSION}-${CI_COMMIT_REF_NAME}" \
            --build-arg VCS_REF="${CI_COMMIT_SHA}" \
            --build-arg BUILD_DATE="$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
            --tag "parity/parity:${VERSION}-${CI_COMMIT_REF_NAME}" \
            --file tools/parity.Dockerfile .;
        docker push "parity/parity:${VERSION}-${CI_COMMIT_REF_NAME}";;
esac

docker logout
