# start with a base image
FROM ubuntu:14.04

#OPENCV
#Needed to grab some lib

#RUN echo "91.189.88.46    archive.ubuntu.com\n91.189.88.46    security.ubuntu.com" >> /etc/hosts
#RUN sh /etc/init.d/networking restart
RUN echo 'deb http://archive.ubuntu.com/ubuntu precise multiverse' >> /etc/apt/sources.list
RUN cat /etc/apt/sources.list

# install dependencies

RUN apt-get update
RUN apt-get install -y python-software-properties
RUN apt-get install -y software-properties-common

RUN add-apt-repository ppa:kirillshkrogalev/ffmpeg-next
RUN apt-get update

#LIBCCV
RUN apt-get update && apt-get install -y git gcc libpng-dev libjpeg-dev libfftw3-dev make libavcodec-dev libavformat-dev libswscale-dev libdispatch-dev libev-dev libatlas-base-dev libblas-dev libgsl0-dev wget
RUN git clone https://github.com/liuliu/ccv.git
COPY /libccv/make_ccv.sh /
RUN /make_ccv.sh
#LIBCCV END

#OPENCV
RUN apt-get install -y libopencv-dev build-essential checkinstall cmake pkg-config yasm libtiff4-dev libjpeg-dev libjasper-dev libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev libxine-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev libv4l-dev python-dev python-numpy libtbb-dev libqt4-dev libgtk2.0-dev libfaac-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev x264 v4l-utils ffmpeg

RUN apt-get install -y unzip wget
WORKDIR /tmp
RUN wget https://github.com/Itseez/opencv/archive/2.4.8.zip
RUN unzip 2.4.8.zip

WORKDIR /tmp/opencv-2.4.8
RUN mkdir /tmp/opencv-2.4.8/build

WORKDIR /tmp/opencv-2.4.8/build

RUN cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_TBB=ON -D BUILD_NEW_PYTHON_SUPPORT=ON -D WITH_V4L=ON -D INSTALL_C_EXAMPLES=ON -D INSTALL_PYTHON_EXAMPLES=ON -D BUILD_EXAMPLES=ON -D WITH_QT=ON -D WITH_OPENGL=ON ..
RUN make -j2
RUN make install
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf
RUN ldconfig

WORKDIR /
RUN rm -rf /tmp/*
#OPENCV END




#OCR
RUN apt-get install -y autoconf automake libtool
RUN apt-get install -y libpng12-dev
RUN apt-get install -y libjpeg62-dev
RUN apt-get install -y g++
RUN apt-get install -y libtiff4-dev
RUN apt-get install -y libopencv-dev libtesseract-dev
RUN apt-get install -y git
RUN apt-get install -y cmake
RUN apt-get install -y build-essential
RUN apt-get install -y libleptonica-dev
RUN apt-get install -y liblog4cplus-dev
RUN apt-get install -y libcurl3-dev
RUN apt-get install -y python2.7-dev
RUN apt-get install -y tk8.5 tcl8.5 tk8.5-dev tcl8.5-dev
RUN apt-get build-dep -y python-imaging --fix-missing
RUN apt-get install -y imagemagick
RUN apt-get install -y wget
RUN apt-get install -y python python-pip


#LEPTONICA
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

ADD requirements.txt /
RUN pip install -r requirements.txt

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

# update working directories
ADD ./flask_server /flask_server
WORKDIR /flask_server

EXPOSE 80
CMD ["python", "app.py"]
