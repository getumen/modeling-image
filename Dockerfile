FROM nvidia/cuda:10.2-devel-ubuntu18.04

ENV DEBIAN_FRONTEND=noninteractive

ENV USER yoshihiro
ENV HOME /home/${USER}
ENV SHELL /bin/bash

RUN useradd -m ${USER} && \
    gpasswd -a ${USER} sudo && \
    echo "${USER}:password" | chpasswd && \
    sed -i.bak "s#${HOME}:#${HOME}:${SHELL}#" /etc/passwd && \ 
    bash -xc "apt-get update && \
    apt-get install -y \
     python3-pip \
     python3-numpy \
     python-scipy \
     python3-matplotlib \
     zip \
     nvidia-driver-418 \
     nvidia-384 \
     nvidia-opencl-icd-384 \
     nvidia-opencl-dev \
     opencl-headers \
     git \
     cmake \
     build-essential \
     libboost-dev \
     libboost-system-dev \
     libboost-filesystem-dev && \
    pip3 install -U setuptools numpy scipy scikit-learn tensorflow pandas matplotlib jupyterlab seaborn optuna && \
    pushd /tmp/ && \
    git clone --recursive https://github.com/microsoft/LightGBM && \
    pushd LightGBM && \
    mkdir build && \ 
    pushd build && \
    cmake -DUSE_GPU=1 -DOpenCL_LIBRARY=/usr/local/cuda/lib64/libOpenCL.so -DOpenCL_INCLUDE_DIR=/usr/local/cuda/include/ .. && \
    make -j$(nproc) && \
    popd && \
    pushd python-package/ && \
    python3 setup.py install --precompile && \
    mkdir -p /etc/OpenCL/vendors && \ 
    echo '/usr/lib/x86_64-linux-gnu/libnvidia-opencl.so.1' > /etc/OpenCL/vendors/nvidia.icd && \
    popd && popd && popd && \
    apt-get autoremove -y \
    " && \
    mkdir /workspace

USER ${USER}
WORKDIR /workspace
EXPOSE 8888

CMD ["bash", "-c", "jupyter lab --notebook-dir=/workspace --port=8888 --ip 0.0.0.0 --no-browser --allow-root"]
