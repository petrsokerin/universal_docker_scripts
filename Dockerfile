FROM nvidia/cuda:11.3.1-base-ubuntu20.04

# Remove any third-party apt sources to avoid issues with expiring keys.
RUN rm -f /etc/apt/sources.list.d/*.list

ARG DEBIAN_FRONTEND=noninteractive
# Install some basic utilities
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    sox \
    tmux \
    libsox-dev \
    libsox-fmt-all \
    build-essential \
    ca-certificates \
    sudo \
    git \
    bzip2 \
    libx11-6 \
    ffmpeg \
    libsm6 \
    libxext6 \
    unzip \
 && rm -rf /var/lib/apt/lists/*


# Create a working directory
RUN mkdir /app
WORKDIR /app

ARG DOCKER_NAME
ARG DOCKER_USER_ID
ARG DOCKER_GROUP_ID

USER root
RUN groupadd -g $DOCKER_GROUP_ID $DOCKER_NAME

RUN adduser --disabled-password --uid $DOCKER_USER_ID --gid $DOCKER_GROUP_ID --gecos '' --shell /bin/bash $DOCKER_NAME \
 && chown -R $DOCKER_NAME:$DOCKER_NAME /app
RUN echo "$DOCKER_NAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-$DOCKER_NAME
USER $DOCKER_NAME

ENV HOME=/home/$DOCKER_NAME

RUN mkdir $HOME/.cache $HOME/.config \
 && chmod -R 777 $HOME

COPY requirements.txt /app/requirements.txt
# Set up the Conda environment
ENV CONDA_AUTO_UPDATE_CONDA=false \
    PATH=$HOME/miniconda/bin:$PATH

RUN curl -sLo ~/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-py39_23.1.0-1-Linux-x86_64.sh \
 && chmod +x ~/miniconda.sh \
 && ~/miniconda.sh -b -p ~/miniconda \
 && rm ~/miniconda.sh \
 && pip install -r requirements.txt \
 && rm /app/requirements.txt \
 && conda clean -ya

CMD jupyter notebook --allow-root --ip='0.0.0.0' --port=8890 --NotebookApp.token='' --NotebookApp.password=''