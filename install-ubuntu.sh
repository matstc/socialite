#!/bin/bash
echo 'This bash script will install Socialite on a box running Ubuntu.'
echo 'You will need to provide your sudo password if you are missing required packages.'
echo ''

# $1 = package name
function install_package {
    dpkg -S $1 >/dev/null
    installed=$?
    if [ $installed -ne 0 ]; then
        echo "Installing the $1 package"
        sudo apt-get -y install $1 || exit 1
    fi

    dpkg -S $1 >/dev/null
    installed=$?
    if [ $installed -ne 0 ]; then
        echo "Could not install the $1 package -- please install it." && exit 1
    fi
}

# $1 = package name
# $2 = binary name
function install_app {
    which $2 >/dev/null
    installed=$?
    if [ $installed -ne 0 ]; then
        echo "Installing $1"
        sudo apt-get -y install $1 || exit 1
    fi

    which $2 >/dev/null
    installed=$?
    if [ $installed -ne 0 ]; then
        echo "Cannot find $1 on the path -- please install it." && exit 1
    fi
}

# $1 = package name
# $2 = binary name
function install_gem {
    ruby -e "require 'rubygems'; require '$1'" &>/dev/null
    installed=$?
    if [ $installed -ne 0 ]; then
        echo "Installing the $1 gem"
        sudo gem install $1 || exit 1
    fi

    ruby -rubygems -e "require '$1'" &>/dev/null
    installed=$?
    if [ $installed -ne 0 ]; then
        echo "Could not load the $1 gem -- please install it." && exit 1
    fi
}

install_app ruby ruby
install_app rubygems gem
install_gem bundler bundle

install_package ruby-dev
install_package g++
install_package libsqlite3-dev

install_app git git

which bundle >/dev/null
gems_on_path=$?
if [ $gems_on_path -ne 0 ];then
    gem_paths=`ruby -rubygems -e 'puts Gem.path.map{|p| "#{p}/bin"}.join(":")'`
    echo ""
    echo "WARNING: The gem binaries were not found on the path. Make sure they are added to the path by running the following command:"
    echo ""
    echo "  export PATH=$PATH:$gem_paths"

    export PATH=$PATH:$gem_paths
    which bundle >/dev/null
    if [ $? -ne 0 ];then
        echo "Could not find the bundler gem on the path -- please install it." && exit 1
    fi
fi

echo ""
echo "All the pre-requisites for running your own instance of Socialite are now installed."
echo ""
echo "Cloning the git repository"

git clone git://github.com/matstc/socialite.git || exit 1
cd socialite || exit 1
bundle || exit 1

echo ""
echo "You should now initialize your app by going into `pwd` and running the following command."
echo "Make sure to specify your own administrator username and password:"
echo ""
echo "  rake production:initialize[username,password]"
echo ""
