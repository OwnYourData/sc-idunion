#!/bin/bash

CONTAINER="sc-idunion"
REPOSITORY="semcon"

# read commandline options
BUILD_CLEAN=false
DOCKER_UPDATE=false
BUILD_ARM=false
BUILD_X86=true
DOCKERFILE="./docker/Dockerfile"

while [ $# -gt 0 ]; do
    case "$1" in
        --clean*)
            BUILD_CLEAN=true
            ;;
        --dockerhub*)
            DOCKER_UPDATE=true
            ;;
        --arm*)
            BUILD_X86=false
            BUILD_ARM=true
            ;;
        --x86*)
            BUILD_X86=true
            BUILD_ARM=false
            ;;
        --issuer*)
            DOCKERFILE="./docker/Dockerfile_issuer"
            CONTAINER="sc-issuer"
            ;;
        --verifier*)
            DOCKERFILE="./docker/Dockerfile_verifier"
            CONTAINER="sc-verifier"
            ;;
        *)
            printf "unknown option(s)\n"
            if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
                return 1
            else
                exit 1
            fi
    esac
    shift
done


if $BUILD_X86; then
    if $BUILD_CLEAN; then
        docker build --platform linux/amd64 --no-cache -f $DOCKERFILE -t $REPOSITORY/$CONTAINER .
    else
        docker build --platform linux/amd64 -f $DOCKERFILE -t $REPOSITORY/$CONTAINER .
    fi
elif $BUILD_ARM; then
    if $BUILD_CLEAN; then
        docker build --platform linux/arm64 --no-cache -f ${DOCKERFILE}.arm64 -t $REPOSITORY/$CONTAINER .
    else
        docker build --platform linux/arm64 -f ${DOCKERFILE}.arm64 -t $REPOSITORY/$CONTAINER .
    fi
fi

if $DOCKER_UPDATE; then
    docker push $REPOSITORY/$CONTAINER
fi
