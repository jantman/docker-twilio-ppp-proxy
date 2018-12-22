#!/bin/bash -e

gitver=$(git rev-parse --short HEAD)
[ -z "$(git status --porcelain)" ] || gitver=${gitver}-dirty
gitrmt=$(git config remote.origin.url)
docker build \
    --build-arg "git_version=${gitver}" \
    --build-arg "git_remote=${gitrmt}" \
    -t jantman/twilio-ppp-proxy:${gitver} \
    .

docker tag jantman/twilio-ppp-proxy:${gitver} jantman/twilio-ppp-proxy:latest
