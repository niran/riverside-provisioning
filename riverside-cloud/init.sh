#!/bin/bash

# -----------------------
# Create non-root user(s)
# -----------------------

NEW_USER="niran"
adduser --disabled-password $NEW_USER

# Allow the new user to sudo
usermod -aG sudo $NEW_USER
echo "$NEW_USER ALL=(ALL:ALL) NOPASSWD:ALL" | sudo EDITOR='tee -a' visudo

# Create .ssh directory for the new user
mkdir -p /home/$NEW_USER/.ssh
chmod 700 /home/$NEW_USER/.ssh
chown $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh

# Set up authorized_keys for the new user
PUBLIC_KEYS=(
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIDEjY3ipLQxhCc8masHc1BnfpeNX0IIBP0xUaehwRbu niran@niran.org (pixelbook)"
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDlJhx0uYEDiTWrfSkMN2305sd1oeOyLoAGaVSaqeCWTQWgNBiIajViMjsMJEDmTa1Cb/Cc4RV4UoI36v6XlCG3w0BFwT8xsA0aXyLLAbD7+zYWMRoXKaAlloMAZl4DCjVR4GIz0CWblA6AWnVOdpKBzNzn4Hjf4FFfj8u6cnsyXrFqve//cNQkC6xZvkZHOWXdLyAaFMUHftiXg3LdOzlanaiWVZru6GOE1Of2n7inAxA0+Td3QuEUy9/+oLvCS084DfVOHpRJmqAUKtjCMx5S4XeWKHcmAVrfKTql3sDeB7ETROVzZe81PcvrCYUOmE1DM0DljAZ6psW+LtPX0KzN8/7nwpIJndjIuelZW6fbQEWhIt7Njt9iNChnCLqohjhWnRBKCrB3wk4K6K4ud/djFCDSpOpjFsSkDm7GjU9XaAqJtoHOgqq7VTv+Hmmg9qSdU31sfAmmXsm0onVP63qdMuIFEA4ptK2CFnzq4DUdF7GtWWNBb2w7ad+mjzMSEKk= oyeniranbabalola@docker"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ3GFMO7/WcggUDX/sYgJ1YjwXX3iNCtiVV7P6f4suga pixel"
  # Add more keys here
)

# Ensure the .ssh directory exists and has correct permissions
mkdir -p /home/$NEW_USER/.ssh
chmod 700 /home/$NEW_USER/.ssh

# Add each public key to the authorized_keys file
for KEY in "${PUBLIC_KEYS[@]}"; do
    echo $KEY >> /home/$NEW_USER/.ssh/authorized_keys
done

# Set permissions for authorized_keys
chmod 600 /home/$NEW_USER/.ssh/authorized_keys
chown $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh/authorized_keys


# --------
# Hostname
# --------

hostnamectl set-hostname riverside

# ----------
# EBS Volume
# ----------

# A brand new EBS volume needs a filesystem formatted on it before mounting. XFS was the
# example filesystem in the AWS docs, so that's what was used when this was written.
# After formatting, the resulting UUID is used in /etc/fstab to mount it at startup.

EBS_UUID="b9b7fd82-9090-48c8-8960-7331d81a7934"
echo "UUID=$EBS_UUID  /workspace  xfs  defaults,nofail  0  2" >> /etc/fstab
mkdir -p /workspace

EBS_DOCKER_UUID="6e8610a8-0926-4a95-8760-660508594791"
echo "UUID=$EBS_DOCKER_UUID  /var/lib/docker  xfs  defaults,nofail  0  2" >> /etc/fstab
mkdir -p /var/lib/docker

mount -a

# ------
# Docker
# ------

# Add Docker's official GPG key:
apt-get update
apt-get install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg


# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
usermod -aG docker $NEW_USER

# ----------
# Github CLI
# ----------

type -p curl >/dev/null || (apt update && apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && apt update \
  && apt install gh -y

# ------------------
# Visual Studio Code
# ------------------

curl -L "https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64" -o vscode-cli-amd64.tar.gz
tar -xzf vscode-cli-amd64.tar.gz -C /usr/local/bin

# ---------------
# Update packages
# ---------------

apt update && apt upgrade -y -q
