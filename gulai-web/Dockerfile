FROM ubuntu:22.04
 
# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget curl bzip2 ca-certificates git \
    netcat-openbsd \
&& rm -rf /var/lib/apt/lists/*
 
# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh
 
# Add conda to PATH
ENV PATH="/opt/conda/bin:$PATH"
 
 
# Accept Anaconda TOS for pkgs/main and pkgs/r
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
 
RUN conda config --set channel_priority flexible
 
# Copy environment file
COPY gulai-django/environment.yml /tmp/environment.yml
 
# Create conda env
RUN conda env create -f /tmp/environment.yml
 
SHELL ["conda", "run", "-n", "gulai-django", "/bin/bash", "-c"]
 
# Copy rest of your code
WORKDIR /app
COPY . /app
 
# Entrypoint
ENTRYPOINT ["/app/entrypoint-dev.sh"]
