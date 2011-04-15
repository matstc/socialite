#!/bin/bash
echo 'This bash script will install Socialite on a box running Ubuntu.'
echo 'You will need to run this script as root if you are missing required packages.'
echo ''

# $1 = package name
function install_package {
    dpkg -S $1 >/dev/null
    installed=$?
    if [ $installed -ne 0 ]; then
        echo "Installing the $1 package"
        apt-get -y install $1 || exit 1
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
        apt-get -y install $1 || exit 1
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
        gem install $1 || exit 1
    fi

    ruby -e "require 'rubygems'; require '$1'" &>/dev/null
    installed=$?
    if [ $installed -ne 0 ]; then
        echo "Could not load the $1 gem -- please install it." && exit 1
    fi
}

which apt-get >/dev/null
apt_get_installed=$?
which ruby >/dev/null
ruby_installed=$?
which gem >/dev/null
gem_installed=$?
which git >/dev/null
git_installed=$?

if [ $apt_get_installed -ne 0 ];then
    if [ $ruby_installed -ne 0 || $git_installed -ne 0 || $gem_installed -ne 0 ]; then
        echo 'apt-get is not on the path -- you might have to run this script as root.'; exit 1
    fi
fi

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
    echo ""
    echo "WARNING: The gem binaries were not found on the path. Make sure they are added to the path by running the following command:"
    ruby -rubygems -e 'puts "> export PATH=$PATH:" + Gem.path.map{|p| "#{p}/bin"}.join(":")'
fi

echo ""
echo "All the pre-requisites for running your own instance of Socialite are now installed."
echo "You should now clone the git repository by running the following command:"
echo "> git clone git://github.com/matstc/socialite.git"
echo ""
echo "Then go into the new checkout and bundle up your app:"
echo "> cd socialite"
echo "> bundle"
echo ""
echo "And then intialize your app (specify your own administrator username and password):"
echo "> rake production:initialize[username,password]"
echo ""
