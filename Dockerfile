# start with a base image
FROM rtux/ubuntu-opencv

#OCR
RUN apt-get install -y \
    autoconf \
    automake \
    libtool \
    libpng12-dev \
    libjpeg62-dev \
    g++ \
    libtiff4-dev \
    libopencv-dev \
    libtesseract-dev \
    git \
    cmake \
    build-essential \
    libleptonica-dev \
    liblog4cplus-dev \
    libcurl3-dev \
    python2.7-dev \
    tk8.5 tcl8.5 tk8.5-dev tcl8.5-dev

RUN apt-get build-dep -y python-imaging --fix-missing

RUN apt-get install -y imagemagick \
    wget

RUN apt-get install -y python \
    python-pip \
    libatlas-base-dev \
    pkg-config \
    libfreetype6-dev \
    libpng12-dev \
    libjpeg62-dev \
    libatlas-base-dev \
    gfortran \
    python-scipy \
    python-matplotlib

#PIP requirements
ADD requirements.txt /
RUN pip install -r requirements.txt

# Current version is at 1.72
# build leptonica
RUN wget http://www.leptonica.org/source/leptonica-1.70.tar.gz
RUN tar -zxvf leptonica-1.70.tar.gz
WORKDIR leptonica-1.70/
RUN ./autobuild
RUN ./configure
RUN make
RUN make install
RUN ldconfig
WORKDIR /
RUN ls

# build tesseract
RUN wget https://tesseract-ocr.googlecode.com/files/tesseract-ocr-3.02.02.tar.gz
RUN tar -zxvf tesseract-ocr-3.02.02.tar.gz
WORKDIR tesseract-ocr/
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install
RUN ldconfig
RUN cd ..

# download the relevant Tesseract English Language Packages
RUN wget https://tesseract-ocr.googlecode.com/files/tesseract-ocr-3.02.eng.tar.gz
RUN tar -xf tesseract-ocr-3.02.eng.tar.gz
RUN sudo cp -r tesseract-ocr/tessdata /usr/local/share/
#OCR END


#LIBCCV
RUN apt-get update && apt-get install -y \
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


# update working directories
ADD ./flask_server /flask_server
WORKDIR /flask_server

EXPOSE 80
CMD ["python", "app.py"]
