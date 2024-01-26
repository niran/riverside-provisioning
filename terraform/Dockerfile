FROM ubuntu:22.04

RUN apt update && apt upgrade -y
RUN apt install wget gpg lsb-release unzip -y

# Install Terraform
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
RUN apt update && apt install terraform -y

# Install AWS CLI
ARG TARGETARCH
RUN if [ "$TARGETARCH" = "arm64" ]; \
  then wget "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -O "awscliv2.zip"; \
  else wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -O "awscliv2.zip"; \
  fi
RUN unzip awscliv2.zip
RUN ./aws/install

RUN mkdir -p /project

# Since this container is intended for use with bind mounts, the user needs
# to be able to specify their uid and gid to match the host machine.
ARG UID=1001
ARG GID=1001

RUN groupadd -g "${GID}" runner && \
  useradd --create-home --no-log-init -u "${UID}" -g "${GID}" runner

USER runner:runner
RUN mkdir -p /home/runner/.terraform.d/plugin-cache

WORKDIR /project

CMD [ "bash" ]
