# docker run -it perl:5.36.0-slim-bullseye /bin/bash
# docker run -p 5000:5000 -it test /bin/bash

BASE="$(dirname $(realpath $0))"
cd "$BASE/../docker"

docker build . -t test:latest