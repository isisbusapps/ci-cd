#!/bin/bash
sudo docker image prune -f -a --filter "until=168h"
sudo docker container prune -f --filter "until=168h"