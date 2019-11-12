#!/bin/bash
source utils.sh

PYTORCH_VIRTUAL_ENV_NAME="pytorch"
TORCH_URL="https://nvidia.box.com/shared/static/06vlvedmqpqstu1dym49fo7aapgfyyu9.whl"
TORCH_WHL="torch-1.2.0a0+8554416-cp36-cp36m-linux_aarch64.whl"
TORCH_VISION_VERSION="v0.4.0"

# Setup pip and python3 dev 
sudo apt update \
&& sudo apt-get -y install python3-pip \
libatlas-base-dev gfortran libhdf5-serial-dev hdf5-tools \
python3-dev

# Install virutal environments
sudo pip3 install virtualenv virtualenvwrapper

# Setting virtual env. paths
appendBashrc "WORKON_HOME=$HOME/.virtualenvs"
appendBashrc 'VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3'
appendBashrc 'source /usr/local/bin/virtualenvwrapper.sh'

mkvirtualenv "$PYTORCH_VIRTUAL_ENV_NAME" -p python3
workon "$PYTORCH_VIRTUAL_ENV_NAME"

# Install pytorch for Jetson
# Source: https://devtalk.nvidia.com/default/topic/1049071/jetson-nano/pytorch-for-jetson-nano-version-1-3-0-now-available/
wget $TORCH_URL -O $TORCH_WHL
pip3 install numpy $TORCH_WHL && rm $TORCH_WHL

# TorchVision
sudo apt-get -y install libjpeg-dev zlib1g-dev
echo 'Starting TorchVision Build - will take a little bit'
git clone --branch $TORCH_VISION_VERSION https://github.com/pytorch/vision torchvision \
&& cd torchvision && sudo python3 setup.py install && cd ..

# https://stackoverflow.com/questions/23929235/multi-line-string-with-extra-space-preserved-indentation
ASSERT_SCRIPT=$(cat <<-END
#!/usr/bin/python3
import sys

if __name__ == "__main__":
    try:
        import torch
        if torch.cuda.is_available():
            sys.exit("true")
    except Exception as e:
        sys.exit(f"false, str(e)")
END
)

# https://vividcode.io/return-value-from-python-script-to-bash-shell/
INSTALLED=$(python3 -c "$ASSERT_SCRIPT" 2>&1 > /dev/null)
echo "PyTorch imported and cuda available: $INSTALLED"
