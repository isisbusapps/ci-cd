FROM ubuntu:latest

RUN apt-get update && apt-get install -y --no-install-recommends  \
    git \
    curl \
    ca-certificates \
    python3 \
    python3-venv \
    python3-pip

# mikefarah/yq (Go) - NOT the Ubuntu 'yq' apt package (python/jq wrapper),
# which lacks the 'e' subcommand the CI workflows rely on.
RUN YQ_VERSION="v4.48.1" && \
    curl -fsSL -o /usr/local/bin/yq \
      "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" && \
    echo "99df6047f5b577a9d25f969f7c3823ada3488de2e2115b30a0abb10d9324fd9f  /usr/local/bin/yq" | sha256sum --check && \
    chmod 0755 /usr/local/bin/yq

RUN VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)" && \
    curl -fsSLO "https://dl.k8s.io/release/${VERSION}/bin/linux/amd64/kubectl" && \
    curl -fsSLO "https://dl.k8s.io/release/${VERSION}/bin/linux/amd64/kubectl.sha256" && \
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl kubectl.sha256

# Install Maven from Apache's official binary distribution.
ARG MAVEN_VERSION=3.9.9
RUN curl -fsSL "https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" \
        | tar -xz -C /opt/ \
    && ln -s "/opt/apache-maven-${MAVEN_VERSION}/bin/mvn" /usr/local/bin/mvn

RUN apt-get purge -y curl && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]