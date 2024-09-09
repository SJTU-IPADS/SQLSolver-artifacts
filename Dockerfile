# Build based on the SQL Server Docker image

FROM mcr.microsoft.com/mssql/server:2022-latest
WORKDIR /app

# Install Python

USER root
RUN apt-get update
RUN apt-get install -y python3 python2 python-is-python3

# Configure Lean PATH

RUN echo "export PATH=$PATH:/app/lean/bin" >> ~/.bashrc

# Install Java-related dependencies (Java, Maven, Gradle)

RUN apt-get install -y curl zip unzip
RUN curl -s "https://get.sdkman.io" | bash

SHELL ["/bin/bash", "-c"]    

RUN source "/root/.sdkman/bin/sdkman-init.sh"     \
                && sdk install java 17.0.12-amzn  \
                && sdk install maven 3.9.6        \
                && sdk install gradle 7.3.3

# Install sqlcmd (the client of SQL Server)

RUN curl https://packages.microsoft.com/keys/microsoft.asc | tee /etc/apt/trusted.gpg.d/microsoft.asc
RUN apt-get install -y software-properties-common
RUN add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/22.04/prod.list)"
RUN apt-get update && apt-get install sqlcmd

# Libraries required by z3

RUN apt-get install -y libgomp1
