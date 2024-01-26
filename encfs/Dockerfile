FROM ubuntu:22.04

RUN apt update && apt upgrade -y
RUN apt install -y encfs p7zip-full

# Since this container is intended for use with bind mounts, the user needs
# to be able to specify their uid and gid to match the host machine.
ARG UID=1001
ARG GID=1001

RUN groupadd -g "${GID}" runner && \
  useradd --create-home --no-log-init -u "${UID}" -g "${GID}" runner

USER runner:runner
WORKDIR /home/runner

CMD [ "bash" ]
