# FROM nvcr.io/nvidia/pytorch:21.09-py3
FROM nvcr.io/nvidia/pytorch:22.12-py3
ENV DEBIAN_FRONTEND=noninteractive 

# dependencies for gym
#
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
 libxcursor-dev \
 libxrandr-dev \
 libxinerama-dev \
 libxi-dev \
 mesa-common-dev \
 zip \
 unzip \
 make \
 gcc-8 \
 g++-8 \
 vulkan-utils \
 mesa-vulkan-drivers \
 pigz \
 git \
 libegl1 \
 git-lfs

# Force gcc 8 to avoid CUDA 10 build issues on newer base OS
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 8
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 8

# WAR for eglReleaseThread shutdown crash in libEGL_mesa.so.0 (ensure it's never detected/loaded)
# Can't remove package libegl-mesa0 directly (because of libegl1 which we need)
RUN rm /usr/lib/x86_64-linux-gnu/libEGL_mesa.so.0 /usr/lib/x86_64-linux-gnu/libEGL_mesa.so.0.0.0 /usr/share/glvnd/egl_vendor.d/50_mesa.json

COPY docker/nvidia_icd.json /usr/share/vulkan/icd.d/nvidia_icd.json
COPY docker/10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json

WORKDIR /opt/isaacgym
COPY LEAP_Hand_Sim python/LEAP_Hand_Sim

RUN chmod -R 777 /opt/isaacgym/python/LEAP_Hand_Sim

RUN useradd --create-home gymuser
USER gymuser

# copy gym repo to docker
COPY --chown=gymuser . .

# install gym modules
ENV PATH="/home/gymuser/.local/bin:$PATH"
RUN cd python && pip install -q -e .

WORKDIR /opt/isaacgym/python/LEAP_Hand_Sim
RUN pip install matplotlib gitpython numpy==1.20.3 wandb
RUN pip install -q -e .
# RUN python3 -m pip install \
#     gym \
#     torch \ 
#     omegaconf \ 
#     termcolor \
#     hydra-core>=1.1 \
#     rl-games==1.5.2 \
#     pyvirtualdisplay
# RUN pip uninstall numpy 
RUN pip install numpy==1.22
RUN pip install protobuf==3.20.* && cd leapsim

ENV NVIDIA_VISIBLE_DEVICES=all NVIDIA_DRIVER_CAPABILITIES=all
