#!/bin/bash
export log_file=$HOME/install_progress_log.txt
export repo=$HOME/server-script

println() {
    echo -ne "\n$1"
    echo "======================\n"
}

println "Disable root user..."
sudo passwd -l root

println "Add user..."
adduser deploy

println "Add user to sudo..."
usermod -aG sudo deploy
cp -r ~/.ssh /home/sammy
chown -R sammy:sammy /home/sammy/.ssh

println "Initiating..."
sudo apt -y update

println "Installing utils..."
sudo apt -y install \
    apt-transport-https \
    autoconf \
    automake \
    ca-certificates \
    cmake \
    curl \
    dirmngr \
    g++ \
    git \
    gnupg2 \
    libncurses5-dev \
    libtool \
    libtool-bin \
    libunibilium-dev \
    libunibilium0 \
    locate \
    make \
    man-db \
    openssh-server \
    pkg-config \
    python-pip \
    python3-pip \
    silversearcher-ag \
    software-properties-common \
    tig \
    ufw \
    whois \
    wget

println "Enable firewall..."
ufw allow OpenSSH
ufw enable
ufw status

println "Installing nvm..."
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
command -v nvm

println "Installing node..."
nvm install node

println "Installing yarn..."
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install yarn

println "Installing fasd..."
wget -c https://github.com/clvv/fasd/tarball/1.0.1 -O - | tar -xz
cd clvv-fasd-4822024/
make install
cd ../
rm -rf clvv-fasd-4822024/

println "Installing bash-it..."
git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
~/.bash_it/install.sh
source /root/.bashrc

# enable completion/plugin/alias
bash-it enable completion dirs docker docker-compose git go
bash-it enable alias git docker docker-compose
bash-it enable plugin git docker docker-compose fasd

# add custom alias
cp $repo/aliases/custom.aliases.bash $HOME/.bash_it/aliases/

# use bakke theme
sed -i 's/bobby/bakke/g' .bashrc

println "Installing neovim..."
curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
chmod u+x nvim.appimage
pip2 install neovim
pip3 install neovim

println "Install color..."
tic -x $repo/color/xterm-256color-italic.terminfo
tic -x $repo/color/tmux-256color-italic.terminfo

println "Update packages..."
sudo apt -y update

println "installing to ~/.config"
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
