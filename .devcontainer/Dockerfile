FROM ros:humble-ros-base

# Replace APT source if your're in Mainland China
RUN sed -i 's|http://archive.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list && \
    sed -i 's|http://ports.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list && \
    sed -i 's|http://security.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list && \
    rm -f /etc/apt/sources.list.d/ros2.sources && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros2-archive-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/ros2/ubuntu jammy main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN apt update && \
    apt -y upgrade && \
    apt install -y ros-humble-rmw-cyclonedds-cpp ros-humble-rosidl-generator-dds-idl ros-humble-cv-bridge ros-humble-sophus ros-humble-pcl-ros ros-humble-foxglove-bridge ros-humble-foxglove-msgs ros-humble-octomap-server ros-humble-rosbag2-storage-mcap ros-humble-image-pipeline libeigen3-dev libopencv-dev libboost-all-dev && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/* && \
    mkdir -p /var/cache/apt/archives/partial && \
    rm -rf /var/log/*
