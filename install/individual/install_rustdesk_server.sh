#!/bin/bash

echo "-----------------------------Installing RustDesk Server-----------------------------"

wget https://raw.githubusercontent.com/techahold/rustdeskinstall/master/install.sh
chmod +x install.sh
./install.sh

echo "Public Key: "
echo ""
cat ./id_ed25519.pub
echo ""