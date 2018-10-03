#!/bin/bash
export log_file=$HOME/install_progress_log.txt
export repo=$HOME/server-script

echo -ne "Initiating...\n"
sudo apt-get -y update

echo -ne "Installing utils...\n"
sudo apt-get -y install git tig 
sudo apt-get -y install make locate
sudo apt-get -y install whois openssh-server
sudo apt-get -y install curl wget dirmngr
sudo apt-get -y install silversearcher-ag
sudo apt-get -y install python-pip
sudo apt-get -y install apt-transport-https ca-certificates software-properties-common

echo -ne "Installing fasd...\n"
wget -c https://github.com/clvv/fasd/tarball/1.0.1 -O - | tar -xz
cd clvv-fasd-4822024/
make install
cd ../
rm -rf clvv-fasd-4822024/

echo -ne "Installing bash-it...\n"
git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
~/.bash_it/install.sh
bash-it enable completion dirs docker docker-compose git go
bash-it enable alias git docker docker-compose
bash-it enable plugin git docker docker-compose fasd
cp $repo/aliases/custom.aliases.bash .bash_it/aliases/

echo -ne "Installing neovim...\n"
sudo apt-get -y install neovim

echo "Install color...\n"
tic -x $repo/color/xterm-256color-italic.terminfo
tic -x $repo/color/tmux-256color-italic.terminfo

echo "Update packages...\n"
sudo apt-get -y update

echo -e "\n\ninstalling to ~/.config"
echo "=============================="
if [ ! -d $HOME/.config ]; then
    echo "Creating ~/.config"
    mkdir -p $HOME/.config
fi
# configs=$( find -path "$repo/config.symlink" -maxdepth 1 )
for config in $repo/config/*; do
    target=$HOME/.config/$( basename $config )
    if [ -e $target ]; then
        echo "~${target#$HOME} already exists... Skipping."
    else
        echo "Creating symlink for $config"
        ln -s $config $target
    fi
done

