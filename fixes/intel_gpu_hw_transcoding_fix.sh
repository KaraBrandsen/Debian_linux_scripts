#!/bin/bash

echo "Applying fix Intel GPU hardware transcoding"

INTEL_GPU=$(lspci -k | grep -EA3 'VGA|3D|Display' | grep "Intel" | xargs)
        
if [ "$INTEL_GPU" != "" ]; then
    DISTRO=$(lsb_release -i | grep "Distributor" | cut -d ':' -f 2 | xargs | cut -d '.' -f 1)

    if [ "$DISTRO" == "Ubuntu" ]; then
        VERSION=$(lsb_release -r | grep "Release" | cut -d ':' -f 2 | xargs)

        echo Intel GPU detected on $DISTRO $VERSION

        if [ "$VERSION" == "22.04" ]; then
            wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | gpg --yes --dearmor --output /usr/share/keyrings/intel-graphics.gpg
            echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu jammy client" | tee /etc/apt/sources.list.d/intel-gpu-jammy.list
            apt update
            apt install -y libze1 intel-level-zero-gpu intel-opencl-icd clinfo linux-image-generic-hwe-22.04 intel-gpu-tools 
        elif [ "$VERSION" == "24.04" ]; then
            wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | gpg --yes --dearmor --output /usr/share/keyrings/intel-graphics.gpg
            echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu noble client" | tee /etc/apt/sources.list.d/intel-gpu-noble.list
            sudo apt update
            apt install -y libze1 intel-level-zero-gpu intel-opencl-icd clinfo linux-image-generic-hwe-24.04 intel-gpu-tools 
        fi
    fi
fi

echo "Successfully applied fix Intel GPU hardware transcoding"