# LEAP_Hand_Suite
Instead of the original conda leaphand repo, we use NVIDIA Docker in this repository

## Installation Guide
We utilize NITROS in NVIDIA Docker Environment. Please ensure that your computer has supported NVIDIA GPU.

### Windows 11 please start with the following pre-installation guide for WSL
First open a powershell and check nvidia driver status:
```
> nvidia-smi
```

### For Ubuntu 22.04 please starts here
1. Install Docker Engine from [this guild](https://docs.docker.com/engine/install/ubuntu/).

2. Configure Docker for rootless access [here](https://docs.docker.com/engine/install/linux-postinstall/).

3. Follow the [Developer Environment Setup](https://nvidia-isaac-ros.github.io/getting_started/dev_env_setup.html) to install nvidia-container-toolkit, Git LFS, and setup `~/workspaces/isaac_ros-dev/src` as `ISAAC_ROS_WS`.

### Install [ISAAC ROS Commons](https://github.com/NVIDIA-ISAAC-ROS/isaac_ros_common)
```
cd ~/workspaces/isaac_ros-dev/src
git clone https://github.com/NVIDIA-ISAAC-ROS/isaac_ros_common.git
```

### Obtain the repository
```
cd ~/workspaces/isaac_ros-dev/src
git clone https://github.com/iaweebowo/LEAP_Hand_Suite
cd LEAP_Hand_Suite
```
### Prepare to run the docker composition
Move the Isaac ROS Common Config file to home
```
cp ./.isaac_ros_common-config ~
```

If you have a Kinova arm, consider using our kinova controll library posted [here](https://github.com/kczttm/ros2_kinova_ws).
Otherwise please configure your docker environment following the guild from [here](https://nvidia-isaac-ros.github.io/concepts/docker_devenv/index.html#development-environment).

### Install Isaacgym & LEAP Hand Sim
1. Install Isaacgym from [this link](https://developer.nvidia.com/isaac-gym)

2. Clone [LEAP_Hand_Sim](https://github.com/leap-hand/LEAP_Hand_Sim) in the {ISAAC_ROS_WS}src/isaacgym directory
Note: {ISAAC_ROS_WS} is the path preceeding your src directory, usually in workspaces/isaac_ros-dev/

3. Replace the Dockerfile and run.sh in {ISAAC_ROS_WS}src/isaacgym/docker with the Dockerfile and run.sh in this repository

### Configure your device
1. Do
```
sudo nano /etc/nvidia-container-runtime/config.toml
```
And change no-cgroups from true to false
```
no-cgroups = false
```
2. Restart your Docker daemon:
```
sudo systemctl restart docker
```
3. Test that it works:
```
sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
```
4. You will need need to find your root window ID. This can be done by running:
```
xdpyinfo
```
And it should be listed under "screen #0" next to "root window id:". Note down the hex value (ex. 0x1111).

## Use Guide
### Entering Docker
We will add the following shortcut to build a docker env according to `~/.isaac_ros_common-config`
```
echo "alias bd='cd ${ISAAC_ROS_WS}src/isaacgym && ./docker/build.sh'" >> ~/.bashrc
echo "alias ld='cd ${ISAAC_ROS_WS}src/isaacgym && ./docker/run.sh ROOT_WINDOW_ID_HERE'" >> ~/.bashrc
```
Make sure you replace ROOT_WINDOW_ID_HERE in the second command with your root window ID found during configuration.
Note that `bd` will build the docker first. `ld` will just launch what has already been built.

Now we start by with a fresh build:
```
source ~/.bashrc
bd
ld
```
