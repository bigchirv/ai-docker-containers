FROM ubuntu:jammy

ENV LC_ALL=C.UTF-8 LANG=C.UTF-8 USE_CUDA=0

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y dist-upgrade \
    && apt-get install -y \
    apt-utils gnupg software-properties-common wget dumb-init ffmpeg git jq liblcms2-2 libz3-4 \
    libtcmalloc-minimal4 pkg-config python3-pip python3-venv \
    && apt-get clean \
    && wget https://repo.radeon.com/amdgpu-install/5.6/ubuntu/jammy/amdgpu-install_5.6.50600-1_all.deb \
    && apt-get install -y ./amdgpu-install_5.6.50600-1_all.deb \
    && amdgpu-install -y --no-dkms --usecase=rocm,hip,mllib --no-32 \
    && rm ./amdgpu-install_5.6.50600-1_all.deb \
    && apt-get update && apt-get -y dist-upgrade && apt-get install -y \
    hip-rocclr llvm-amdgpu \
    && apt-get clean \
    && pip3 install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm5.6