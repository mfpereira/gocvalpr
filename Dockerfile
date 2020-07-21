FROM golang:1.13 as base

RUN apt-get update && apt-get install -y --no-install-recommends \
            git build-essential cmake pkg-config unzip libgtk2.0-dev \
            curl ca-certificates libcurl4-openssl-dev libssl-dev \
            libavcodec-dev libavformat-dev libswscale-dev libtbb2 libtbb-dev \
            libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev && \
            rm -rf /var/lib/apt/lists/*

ARG OPENCV_VERSION="3.4.3"
ENV OPENCV_VERSION $OPENCV_VERSION

RUN curl -Lo opencv.zip https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
            unzip -q opencv.zip && \
            curl -Lo opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip && \
            unzip -q opencv_contrib.zip && \
            rm opencv.zip opencv_contrib.zip && \
            cd opencv-${OPENCV_VERSION} && \
            mkdir build && cd build && \
            cmake -D CMAKE_BUILD_TYPE=RELEASE \
                  -D CMAKE_INSTALL_PREFIX=/usr/local \
                  -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-${OPENCV_VERSION}/modules \
                  -D WITH_JASPER=OFF \
                  -D BUILD_DOCS=OFF \
                  -D BUILD_EXAMPLES=OFF \
                  -D BUILD_TESTS=OFF \
                  -D BUILD_PERF_TESTS=OFF \
                  -D BUILD_opencv_java=NO \
                  -D BUILD_opencv_python=NO \
                  -D BUILD_opencv_python2=NO \
                  -D BUILD_opencv_python3=NO \
                  -D OPENCV_GENERATE_PKGCONFIG=ON .. && \
            make -j $(nproc --all) && \
            make preinstall && make install && ldconfig && \
            cd / && rm -rf opencv*

ENV GO111MODULE=on

#Install OpenALPR and OpenALPR Go binding
RUN apt-get update && apt-get install -y libtesseract-dev liblog4cplus-dev
# Installing OpenALPR Go binding
COPY ./openalpr /openalpr
WORKDIR /openalpr/openalpr-2.3.0/src
RUN cmake ./
#WORKDIR /openalpr/openalpr-2.3.0/src/bindings/go
RUN make && make install

WORKDIR ${GOPATH}/src/app
RUN go mod init
RUN go get -u -d gocv.io/x/gocv@v0.17.0

COPY ./main.go ./
COPY ./lp.jpg ./
COPY ./runtime_data ./runtime_data/
RUN go build -o app -i main.go

CMD ["./app"]
