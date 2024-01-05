#!/bin/bash
BASE_IMAGES=$(echo $(basename -s .dockerfile -a $(ls ./dockerfiles/base-*.dockerfile) | sed -e 's/base-//g'))
IMAGES=$(echo $(basename -s .dockerfile -a $(ls ./dockerfiles/ai-*.dockerfile) | sed -e 's/ai-//g'))

_build() {
  # $1: dockerfile's name
  if [ ! -f "./dockerfiles/$1.dockerfile" ]; then
    echo "Error: './dockerfiles/$1.dockerfile' does not exists. Cannot build."
    exit 1
  fi
  echo -n "Building image '$1': "
  docker build --tag "chirvo/$1:latest" -f "./dockerfiles/$1.dockerfile" .
  [ $? -eq 0 ] && echo "done." || echo "error."
}
_image_rm() {
  #$1 Image
  echo -n "Removing image '$1': "
  docker image rm "chirvo/$1:latest"
  [ $? -eq 0 ] && echo "done." || echo "error."
}

case "$1" in
clean)
  echo "Pruning containers..."
  docker container prune
  for IMAGE in $BASE_IMAGES; do
    _image_rm "base-$IMAGE"
  done
  for IMAGE in $IMAGES; do
    _image_rm "ai-$IMAGE"
  done
  ;;
all)
  echo "Building $1"
  for IMAGE in $BASE_IMAGES; do
    _build "base-$IMAGE"
  done
  for IMAGE in $IMAGES; do
    _build "ai-$IMAGE"
  done
  ;;
*)
  for IMAGE in $BASE_IMAGES; do
    if [ "$1" == "$IMAGE" ]; then
      echo "Found 'base-$1.'"
      _build "base-$1"
      exit 0
    fi
  done
  for IMAGE in $IMAGES; do
    if [ "$1" == "$IMAGE" ]; then
      echo "Found 'ai-$1.'"
      _build "ai-$1"
      exit 0
    fi
  done
  echo "Usage: $0 {clean|all|<image>}"
  echo ""
  echo "Available Base images: $BASE_IMAGES".
  echo "Available AI images: $IMAGES".
  echo ""
  exit 1
  ;;
esac
exit 0