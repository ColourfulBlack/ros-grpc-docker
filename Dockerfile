FROM ubuntu:bionic

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -q && \
    apt-get upgrade -yq && \
    apt-get install -yq wget curl git build-essential lsb-release locales bash-completion autoconf libtool pkg-config libssl-dev make cmake g++ && \
    apt-get clean
RUN git clone --recurse-submodules -b v1.28.0 --depth 1 https://github.com/grpc/grpc && \
    cd grpc && \
    mkdir -p cmake/build && cd cmake/build && cmake -DCMAKE_BUILD_TYPE=Release -DgRPC_INSTALL=ON -DgRPC_BUILD_TESTS=OFF -DCMAKE_CXX_FLAGS=-latomic ../.. && make -j$(nproc) && make install && make clean && ldconfig && \
    rm -rf /grpc
RUN sh -c "curl -k https://apt.kitware.com/keys/kitware-archive-latest.asc | apt-key add - && \
           echo 'deb https://apt.kitware.com/ubuntu/ bionic main' > /etc/apt/sources.list.d/kitware.list"
RUN sh -c "echo 'deb http://packages.ros.org/ros/ubuntu bionic main' > /etc/apt/sources.list.d/ros-latest.list"
RUN curl -k https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | apt-key add -
RUN apt-get update -q && \
    apt-get install -y cmake ros-melodic-desktop-full python-rosdep &&\ 
    rm -rf /var/lib/apt/lists/*
RUN rosdep init
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
RUN rosdep update
RUN mkdir -p ~/catkin_ws/src \
    && /bin/bash -c '. /opt/ros/melodic/setup.bash; catkin_init_workspace $HOME/catkin_ws/src' \
    && /bin/bash -c '. /opt/ros/melodic/setup.bash; cd $HOME/catkin_ws; catkin_make'
RUN echo 'source /opt/ros/melodic/setup.bash' >> ~/.bashrc
CMD ["/bin/bash"]
