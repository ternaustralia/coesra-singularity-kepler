#!/bin/bash -ex

sudo sed -i -e 's/^Defaults\tsecure_path.*$//' /etc/sudoers

# Check Python

echo "--------------------------------------------------------------"
echo "Python Version:"
python --version
echo "--------------------------------------------------------------"
pip install sregistry[all]
sregistry version

echo "sregistry Version:"

# Install Singularity

SINGULARITY_BASE="${GOPATH}/src/github.com/sylabs/singularity"
export PATH="${GOPATH}/bin:${PATH}"

mkdir -p "${GOPATH}/src/github.com/sylabs"
cd "${GOPATH}/src/github.com/sylabs"

# git clone -b release-2.5.1 https://github.com/sylabs/singularity
#cd singularity
wget https://github.com/sylabs/singularity/releases/download/2.5.1/singularity-2.5.1.tar.gz
tar -xvvf singularity-2.5.1.tar.gz
cd singularity-2.5.1
#./mconfig -v -p /usr/local
#make -j `nproc 2>/dev/null || echo 1` -C ./builddir all
#sudo make -C ./builddir install
./configure --prefix=/opt/singularity
make -j `nproc 2>/dev/null || echo 1`
sudo make install
sudo ln -s /opt/singularity/bin/singularity /bin/singularity