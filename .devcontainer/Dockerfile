# Use an official Ubuntu as a parent image
FROM ubuntu:latest

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install basic network tools, Git, Docker CLI, and Terraform
RUN apt-get update \
    && apt-get install -y --no-install-recommends apt-utils dialog 2>&1 \
    && apt-get install -y git iproute2 procps lsb-release \
    && apt-get install -y curl unzip sudo \
    && curl -fsSL https://get.docker.com -o get-docker.sh \
    && sh get-docker.sh \
    && rm get-docker.sh \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - \
    && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    && apt-get update && apt-get install -y terraform

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Setting the ENTRYPOINT to docker daemon
ENTRYPOINT ["dockerd-entrypoint.sh"]
CMD ["sleep", "infinity"]
