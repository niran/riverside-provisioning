FROM ubuntu:22.04

RUN apt update && apt upgrade -y
RUN apt install -y curl
RUN apt install -y ca-certificates curl gnupg
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

ARG NODE_MAJOR=18
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

RUN apt update && apt install -y nodejs

RUN groupadd worker && useradd --no-log-init -m -g worker worker
USER worker:worker
WORKDIR /home/worker


CMD [ "bash" ]
