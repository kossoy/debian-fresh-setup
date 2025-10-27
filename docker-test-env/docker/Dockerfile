FROM debian:stable

# Install minimal requirements for testing
# - sudo: Required by bootstrap scripts
# - wget: For one-liner install (bash <(wget ...))
# - git: For manual clone testing
RUN apt-get update && \
    apt-get install -y sudo wget git && \
    useradd -m -u 1000 -s /bin/bash god && \
    echo 'god ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/god && \
    chmod 0440 /etc/sudoers.d/god && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Switch to user god
USER god
WORKDIR /home/god

CMD ["sleep", "infinity"]
