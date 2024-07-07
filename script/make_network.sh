#!/bin/bash
docker network create --subnet=172.20.0.0/16 --opt com.docker.network.driver.mtu=1500 --opt com.docker.network.bridge.name=janus janus-multi
