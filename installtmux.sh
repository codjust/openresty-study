#!/bin/bash

CURRENT_DIR=$(pwd)

echo "Install libevent..."
wget https://github.com/libevent/libevent/releases/download/release-2.0.22-stable/libevent-2.0.22-stable.tar.gz -P $CURRENT_DIR

tar -xzf libevent-2.0.22-stable.tar.gz 
cd libevent-2.0.22-stable/
./configure && make
sudo make install 

echo "libevent install successful"
echo "Install tmux..."

cd $CURRENT_DIR
git clone https://github.com/tmux/tmux.git
cd tmux/

apt-get install -y libncurses5-dev automake
sh autogen.sh
./configure && make
ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib64/libevent-2.0.so.5 
ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib/libevent-2.0.so.5 

ln -s $CURRENT_DIR/tmux/tmux /usr/bin/

echo "Install tmux successful"

echo "Install tmux plugin..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm 
wget https://github.com/huchangwei/dotfiles/raw/master/.tmux.conf  -P ~
tmux source ~/.tmux.conf 
echo "Plugin install successful!"
echo "execute tmux:"
tmux
