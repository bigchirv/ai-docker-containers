#!/bin/bash
 
USE_CUDA=0

# Try running it with this command if you have issues:
# For 6700, 6600 and maybe other RDNA2 or older:
HSA_OVERRIDE_GFX_VERSION=10.3.0
#PYTORCH_ROCM_ARCH=gfx1030

# For AMD 7600 and maybe other RDNA3 cards: 
#HSA_OVERRIDE_GFX_VERSION=11.0.0
#PYTORCH_ROCM_ARCH=gfx1100


#################
# Common envvars
# 
GIT_URI="https://github.com/AUTOMATIC1111/stable-diffusion-webui"
COMMAND_EXTRA_PARAMS=""
COMMAND="python3 launch.py --listen --enable-insecure-extension-access"
PORT=7860
# generated envvars


_get_dest_dir () {

  local BASE_DIR=$(pwd)
  if [ "$BASE_DIR" == "/" ]; then
    BASE_DIR=""
  fi

  # returns DEST_DIR
  echo "$BASE_DIR/$(basename $GIT_URI .git)"
}

_clone_or_rebase_repo () {
  local DEST_DIR=$(_get_dest_dir)
  if [ -d "$DEST_DIR" ]; then
    echo "Directory exists. Rebasing."
    cd $DEST_DIR
    git rebase
    cd -
  else
    git clone $GIT_URI $DEST_DIR
  fi

  cd $DEST_DIR
  git config --global --add safe.directory '*'
  cd -
}

_install_requirements () {
  local DEST_DIR=$(_get_dest_dir)
  cd $DEST_DIR
  cat requirements.txt | grep -vw torch > /tmp/requirements.txt
  mv /tmp/requirements.txt ./requirements.txt
  pip3 install -r requirements.txt
  cd -
}

_run () {
  local DEST_DIR=$(_get_dest_dir)

  echo "1. Cloning $GIT_URI into $DEST_DIR"
  _clone_or_rebase_repo

  echo "2. Installing requirements"
  _install_requirements

  echo "3. Running the damn thing"

  # run the command
  cd $DEST_DIR
  "$COMMAND $COMMAND_EXTRA_PARAMS"
  cd -
}

run () {
    _run $1
  exit 0
}

case "$1" in
  a1111)	echo "Running AUTOMATIC1111"
    GIT_URI="https://github.com/AUTOMATIC1111/stable-diffusion-webui"
    COMMAND_EXTRA_PARAMS=""
    COMMAND="python3 launch.py --listen --enable-insecure-extension-access"
    PORT=7860
  ;;
  comfy)	echo "Running ComfyUI"
    GIT_URI="https://github.com/comfyanonymous/ComfyUI.git"
    COMMAND_EXTRA_PARAMS=""
    COMMAND="python3 main.py --listen --enable-insecure-extension-access"
    PORT=8180
  ;;
  *) echo "'$1' is not a valid option."
    exit 1
  ;;
esac
run $1
exit 0
