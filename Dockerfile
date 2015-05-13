# start with a base image
FROM rtux/ubuntu-opencv
RUN apt-get update

RUN apt-get install -y
    python \
    python-pip \
    libatlas-base-dev \
    pkg-config \
    libfreetype6-dev \
    libpng12-dev \
    libjpeg62-dev \
    libatlas-base-dev \
    gfortran \
    python-scipy \
    python-matplotlib \
    wget

#PIP requirements
ADD requirements.txt /
RUN pip install -r requirements.txt

#LIBCCV
RUN apt-get install -y \
    git \
    gcc \
    libpng-dev \
    libjpeg-dev \
    libfftw3-dev \
    make \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libdispatch-dev \
    libev-dev \
    libatlas-base-dev \
    libblas-dev \
    libgsl0-dev \
    wget

RUN git clone https://github.com/liuliu/ccv.git
COPY make_ccv.sh /
RUN /make_ccv.sh
#LIBCCV END

