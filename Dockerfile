FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    ROS_DISTRO=noetic \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility,video

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# ROS Noetic is tied to Ubuntu 20.04. Install the ROS repository explicitly
# because the CUDA image does not contain ROS metadata.
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl gnupg2 lsb-release locales software-properties-common \
    && locale-gen en_US.UTF-8 \
    && curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
       | gpg --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros/ubuntu focal main" \
       > /etc/apt/sources.list.d/ros1.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      ros-noetic-ros-base python3-catkin-tools python3-catkin-pkg \
      build-essential cmake pkg-config git libeigen3-dev libgflags-dev \
      libgoogle-glog-dev libusb-1.0-0-dev libdw-dev libboost-filesystem-dev \
      libboost-system-dev libopencv-dev python3-opencv python3-pip \
      libnvinfer-dev python3-libnvinfer tensorrt \
      ros-noetic-camera-info-manager ros-noetic-cv-bridge \
      ros-noetic-dynamic-reconfigure ros-noetic-message-generation \
      ros-noetic-message-runtime ros-noetic-std-srvs \
      ros-noetic-diagnostic-updater ros-noetic-image-geometry \
      ros-noetic-image-transport ros-noetic-image-transport-plugins \
      ros-noetic-compressed-image-transport ros-noetic-message-filters \
      ros-noetic-backward-ros ros-noetic-pluginlib ros-noetic-nodelet \
      ros-noetic-tf2 ros-noetic-tf2-ros ros-noetic-diagnostic-msgs \
    && rm -rf /var/lib/apt/lists/*

# Ubuntu 20.04 provides Python 3.8. The CUDA 12.8 PyTorch index no longer
# publishes cp38 wheels, so pin the last Python 3.8-compatible CUDA wheel.
# The wheel carries its CUDA 12.4 runtime; the container still uses the CUDA
# 12.8 toolkit and TensorRT packages above, and relies on the host NVIDIA
# driver at runtime.
RUN python3 -m pip install --no-cache-dir --upgrade pip \
    && python3 -m pip install --no-cache-dir \
      torch==2.4.1 torchvision==0.19.1 torchaudio==2.4.1 \
      --index-url https://download.pytorch.org/whl/cu124 \
    && python3 -m pip install --no-cache-dir numpy PyYAML

WORKDIR /root/gemini_ws
COPY src /root/gemini_ws/src

RUN source /opt/ros/noetic/setup.bash \
    && catkin_make -DCMAKE_BUILD_TYPE=Release \
    && echo 'source /opt/ros/noetic/setup.bash' >> /root/.bashrc \
    && echo 'source /root/gemini_ws/devel/setup.bash' >> /root/.bashrc

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
