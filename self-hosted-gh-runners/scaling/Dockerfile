FROM ubuntu:latest

RUN apt-get update && apt-get install -y --no-install-recommends  \
    git \
    yq \
    curl \
    ca-certificates
    
RUN VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)" && \
    curl -fsSLO "https://dl.k8s.io/release/${VERSION}/bin/linux/amd64/kubectl" && \
    curl -fsSLO "https://dl.k8s.io/release/${VERSION}/bin/linux/amd64/kubectl.sha256" && \
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl kubectl.sha256

RUN apt-get purge -y curl && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]