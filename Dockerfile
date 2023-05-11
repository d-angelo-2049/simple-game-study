FROM nvidia/cuda:11.4.2-cudnn8-devel-ubuntu20.04

# set timezone to Asia/Tokyo
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# install Anaconda
RUN apt-get update && \
    apt-get install -y wget && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    sh Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && \
    rm Miniconda3-latest-Linux-x86_64.sh && \
    echo "export PATH=/opt/conda/bin:$PATH" >> ~/.bashrc

# Activate conda in non-interactive shell
RUN /opt/conda/bin/conda init bash

# create a new conda environment and activate it
COPY ./simple-game-study-env.yaml /tmp/simple-game-study-env.yaml
RUN /opt/conda/bin/conda env create -f /tmp/simple-game-study-env.yaml
ENV PATH /opt/conda/envs/simple-game-study-env.yaml/bin:$PATH
RUN echo "conda activate simple-game-study-env" >> ~/.bashrc

# clean packages
RUN /opt/conda/bin/conda clean --all --yes

# enable SSH
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN echo "export VISIBLE=now" >> /etc/profile

# expose port 22 for SSH, port 8888 for JupytorLab
EXPOSE 22 8888

# set the working directory to /src
WORKDIR /simple-game-study

# mount the current directory on the host to /src in the container
COPY . /simple-game-study
SHELL ["/bin/bash", "-c", "source ~/.bashrc && conda activate simple-game-study-env.yaml"]
#CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--no-browser", "--allow-root"]