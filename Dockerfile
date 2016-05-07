# Based on official TensorFlow Dockerfile
# (https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/docker/Dockerfile)

FROM ubuntu:16.04

MAINTAINER Low Ker Li <lowkerli@diverta.co.jp>

ENV REFRESHED_AT 2016-04-25

RUN apt-get update && apt-get install -y \
    curl \
    libfreetype6-dev \
    libjpeg9-dev \
    libpng12-dev \
    libzmq3-dev \
    pkg-config \
    python3 \
    python3-dev \
    python3-numpy \
    python3-scipy \
    zlib1g-dev \
 && rm -rf /var/lib/apt/lists/*

# Install pip
RUN curl -O https://bootstrap.pypa.io/get-pip.py \
 && python3 get-pip.py \
 && rm get-pip.py

RUN pip3 --no-cache-dir install \
    jupyter \
    matplotlib \
 && python3 -m ipykernel install
        
# Install TensorFlow CPU version.
# The following is a hack to install TensorFlow for Python 3.5
ENV TENSORFLOW_VERSION 0.8.0
RUN curl https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-${TENSORFLOW_VERSION}-cp34-cp34m-linux_x86_64.whl \
    -o tensorflow-${TENSORFLOW_VERSION}-cp35-cp35m-linux_x86_64.whl \
 && pip3 --no-cache-dir install \
    tensorflow-${TENSORFLOW_VERSION}-cp35-cp35m-linux_x86_64.whl \
 && rm tensorflow-${TENSORFLOW_VERSION}-cp35-cp35m-linux_x86_64.whl

# Install Keras
RUN pip3 --no-cache-dir install \
    keras \
    Pillow

# Copy Keras configurations
# (Set backend to Tensorflow)
COPY .keras/ /root/.keras/

# Set up our notebook config.
COPY jupyter_notebook_config.py /root/.jupyter/

# Jupyter has issues with being run directly:
#   https://github.com/ipython/ipython/issues/7062
# We just add a little wrapper script.
COPY run_jupyter.sh /usr/local/bin/

# TensorBoard
EXPOSE 6006
# IPython
EXPOSE 8888

ENV NOTEBOOKS_DIR /root/notebooks

# Prepare directories for volumes
RUN mkdir -p {${NOTEBOOKS_DIR},/root/{bin,python,data}}

# Create mount points
VOLUME ["${NOTEBOOKS_DIR}", "/root/bin", "/root/python", "/root/data"]

# Add modules path to PYTHONPATH
ENV PYTHONPATH $PYTHONPATH:/root/python/modules

# Add bin and scripts to PATH
ENV PATH $PATH:/root/bin:/root/python/scripts

WORKDIR ${NOTEBOOKS_DIR}

CMD ["run_jupyter.sh"]
