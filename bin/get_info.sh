#!/bin/bash

for i in $(docker container ps | awk '{print $1}' | sed '1d'); do
    echo "docker inspect $i"
    docker inspect $i
done

