#!/usr/bin/env bash

# Run from project root to get NPM dev env

hostname=$(hostname -f)
docker run -ti --rm \
  --name nodelib-dev \
  --domainname nodelib-dev.$hostname \
  --hostname nodelib-dev \
  -v $PWD:/home/treebox/project/nodelib \
  dotmpe/treebox:dev \
  sudo -Hu treebox bash -c "cd ~/project/nodelib && bash"

# Don't run as '--user root' b/c of runit & other baseimage stuff..
# Because of 'sudo' --workdir will have no effect either.
