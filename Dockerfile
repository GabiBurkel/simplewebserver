FROM docker.io/debian:buster-slim

LABEL maintainer="gabiburkel@gabiburkel.de"


# BUILD TIME ARGUMENTS (ARG)
ARG UID=2010
ARG UNAME="server"
ARG GID=2010
ARG GNAME="server"
ARG PORT=9000


# RUNTIME ARGUMENTS (ENV) 
#ENV PORT=9000

# IMAGE SETUP (ADD, RUN, COPY, WORKDIR)
# Create non-root user to use to run the container payload.
# Command looks different on Alpine!


RUN set -x \
  && addgroup --system --gid ${GID} ${GNAME} \
  && adduser --system --disabled-login --ingroup ${GNAME} \
  --no-create-home --home /nonexistent --shell /bin/false \
  --uid ${UID} ${UNAME}

RUN set -x && apt-get update \
  && apt-get install -y python2.7 curl \
  && rm -rf /var/lib/apt/lists/*



# Copy over needed configuration files
# ADD can extract TARs / download files, COPY cannot
RUN mkdir -p /var/www
COPY files/simplewebserver.py /var/www/simplewebserver.py
COPY files/index.html /var/www/index.html

# COPY --chown=0:0 or --chown=root:root is not supported by my minishift set up
# COPY --chown=root:root files/index.html /var/www/index.html


# VOLUME SETUP (VOLUME)
# VOLUME [ "/var/lib/mysql" ]


# RUNTIME SETUP (ENTRYPOINT, CMD, SHELL, EXPOSE, USER,
#                STOPSIGNAL, HEALTCHECK)
# Privilege Drop

USER ${UNAME}:${GNAME}

WORKDIR /var/www

ENTRYPOINT ["/usr/bin/python2.7"]
CMD ["/var/www/simplewebserver.py"]

EXPOSE ${PORT}/tcp 
