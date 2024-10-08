FROM docker.io/aiidateam/aiida-core-with-services:latest AS build 

ARG proxy
ARG workers

ENV WORKER=${workers}
USER root
LABEL org.opencontainers.image.authors="pthibaud@users.noreply.github.com"

RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get autoclean && apt-get autoremove -y 
RUN apt-get install wget git gcc gfortran g++ libblas-dev liblapack-dev libfftw3-dev \
    cmake libxml2-dev libnetcdff-dev libxc-dev python3 python3-dev pip libzstd-dev \
    libopenmpi-dev sudo -y

# Quantum ESPRESSO
WORKDIR /home/dft
RUN git clone https://gitlab.com/QEF/q-e.git
WORKDIR /home/dft/q-e
RUN ./configure --prefix=/usr/local --enable-parallel=yes
RUN make -j ${WORKER} all && make install
WORKDIR /home/dft
RUN rm -fr q-e

# update environment variable to get access to shared libraries
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/lib"

# Wannier90-Workflows
WORKDIR /home/dft
RUN git clone https://github.com/aiidateam/aiida-wannier90-workflows.git

USER aiida

WORKDIR /home/dft/aiida-wannier90-workflows
RUN pip install -e .

# Quantum Espresso + TB2J + AiiDA_Shell 
RUN pip install --user aiida-quantumespresso tb2j aiida_shell

# Jupyter
RUN conda install -y jupyter

WORKDIR /home/aiida

ARG proxy
RUN echo "export https_proxy=${proxy}" >> .bashrc
RUN echo "export http_proxy=${proxy}" >> .bashrc