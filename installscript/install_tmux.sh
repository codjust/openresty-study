#!/bin/bash

set -e

CURRENT_DIR=$(pwd)

echo "Install libevent..."
wget https://github.com/libevent/libevent/releases/download/release-2.0.22-stable/libevent-2.0.22-stable.tar.gz -P $CURRENT_DIR

tar -xzf libevent-2.0.22-stable.tar.gz 
cd libevent-2.0.22-stable/
./configure && make -j4
sudo make install 

echo "libevent install successful"
echo "Install tmux..."

cd $CURRENT_DIR
git clone https://github.com/tmux/tmux.git
cd tmux/

yum install -y automake ncurses-devel
sh autogen.sh
./configure && make -j4 
ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib64/libevent-2.0.so.5 
ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib/libevent-2.0.so.5 

ln -s $CURRENT_DIR/tmux/tmux /usr/bin/tmux 

echo "Install tmux successful"

echo "Install tmux plugin..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm 
wget https://github.com/huchangwei/dotfiles/raw/master/.tmux.conf  -P ~
tmux source ~/.tmux.conf 
echo "Plugin install successful!"
echo "execute tmux:"
tmux
