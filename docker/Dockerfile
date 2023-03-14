FROM perl:5.36.0-slim-bullseye

RUN apt-get update \
    && apt-get -y install gcc \
    && cpanm --no-man-pages Carton Plack \
    && apt-get -y autoremove gcc