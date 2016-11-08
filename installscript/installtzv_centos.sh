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

yum install -y git
cd $CURRENT_DIR
git clone https://github.com/tmux/tmux.git
cd tmux/

yum install -y ncurses-devel  automake
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
sleep(1)


echo "Install zsh...."

yum install -y zsh
curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
rm -f ~/.zshrc 
wget https://github.com/huchangwei/dotfiles/raw/master/.zshrc -P ~
source ~/.zshrc 

echo "Install zsh successful!"

echo "Install vim plugin..."
wget -qO- https://raw.github.com/ma6174/vim/master/setup.sh | sh -x


