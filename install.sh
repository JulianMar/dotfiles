#!/bin/bash

# apt packages

sudo apt-get -y install \
	zsh \
	git \
	vim \
	htop \
	powerline \
	bison \
	libnss3-tools \
	default-jre \
	default-jdk \
	curl

# make zsh the default prompt
chsh -s $(which zsh)

# install oh-my-zsh
if [ ! -d $HOME/.oh-my-zsh ] ; then
	sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
fi

# symlink .zshrc to home
rm $HOME/.zshrc
ln .zshrc $HOME/.zshrc

rm $HOME/.aliasrc
ln .aliasrc $HOME/.aliasrc

rm $HOME/.functionsrc
ln .functionsrc $HOME/.functionsrc

rm $HOME/.envrc
ln .envrc $HOME/.envrc

ln -sf pulse/daemon.conf $HOME/.config/pulse/daemon.conf

sudo ln -sf etc/asound.conf /etc/asound.conf

# install astronaut theme
if [ ! -d $ZSH_CUSTOM/themes/spaceship-prompt ] ; then
	git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
	ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
fi

# Add Auto Suggestions
if [ ! -d $ZSH_CUSTOM/plugins/zsh-autosuggestions ] ; then
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# Install Node via nvm
if [ ! -d $HOME/.nvm ] ; then
	git clone https://github.com/creationix/nvm.git $HOME/.nvm
fi

. $HOME/.nvm/nvm.sh

nvm install node

# Install Docker
if ! type docker > /dev/null ; then
	sudo apt-get update

	sudo apt-get -y install \
		apt-transport-https \
		ca-certificates \
		curl \
		software-properties-common

	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

	sudo add-apt-repository \
	"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	bionic \
	stable"

	sudo apt-get update

	sudo apt-get -y install docker-ce

	sudo usermod -aG docker $USER

fi

# Install Docker Compose
if ! type docker-compose > /dev/null ; then
	sudo apt-get -y install docker-compose
fi

# Install vsCode
if ! type code-insiders > /dev/null ; then
	curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
	sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
	sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

	sudo apt-get -y install apt-transport-https
	sudo apt-get update
	sudo apt-get -y install code-insiders
fi


# Install PHP
sudo apt-get -y install \
	php-cli \
	php-bcmath \
	php-mbstring \
	php-curl \
	php-xdebug \
	php-dom \
	php-mysql

# Install Composer
if [ ! -f $HOME/bin/composer.phar ] ; then
	./composer.sh
fi

# Install Sublime Merge
if ! type smerge > /dev/null ; then
	wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -

	echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

	sudo apt-get update
	sudo apt-get install sublime-merge
fi

# Install laradock
if [ ! -d $HOME/Projects/laradock ] ; then
	git clone https://github.com/Laradock/laradock.git $HOME/Projects/laradock

	cp laradock/.env $HOME/Projects/laradock/.env
fi

OLDPATH=$PWD

cd $HOME/Projects/laradock

docker-compose -v

docker-compose up -d nginx mysql redis

cd $OLDPATH

# Install Go
if ! type go > /dev/null ; then

	zsh < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)

	source $HOME/.gvm/scripts/gvm

	gvm install go1.11.2

	gvm use go1.11.2

	gvm linkthis $HOME/Projects/go

fi

if ! type oc > /dev/null ; then
	VERSION=openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit

	curl -L https://github.com/openshift/origin/releases/download/v3.11.0/$VERSION.tar.gz -o oc.tar.gz -s

	tar -zxf oc.tar.gz $VERSION

	mv $VERSION/oc $HOME/bin/oc
	mv $VERSION/kubectl $HOME/bin/kubectl

	rm -rf $VERSION
	rm oc.tar.gz
fi

if ! type rustup > /dev/null ; then
	curl https://sh.rustup.rs -sSf | sh

	source $HOME/.cargo/env

	rustup update
	rustup component add clippy
fi

if ! type z > /dev/null ; then
	curl -L https://github.com/rupa/z/archive/v1.9.zip -o z.zip -s

	unzip -o z.zip

	mv z-1.9/z.sh $HOME/bin/z.sh

	chmod +x $HOME/bin/z.sh
fi
