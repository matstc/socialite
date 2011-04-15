#!/bin/bash
echo 'This bash script will install Socialite on a box running Ubuntu.'

which apt-get >/dev/null
apt_get_installed=$?
which ruby >/dev/null
ruby_installed=$?
which gem >/dev/null
gem_installed=$?
which git >/dev/null
git_installed=$?
which rake >/dev/null
rake_installed=$?
which bundle >/dev/null
bundler_installed=$?
which rails >/dev/null
rails_installed=$?

if [[ ! apt_get_installed ]];then
    if [[ ! ruby_installed || ! git_installed || ! gem_installed ]]; then
        echo 'apt-get is not on the path -- you might have to run this script as root.' && exit 1
    fi
fi

if [[ ! ruby_installed ]]; then
    echo 'Installing ruby'
    apt-get install ruby || exit 1
fi

if [[ ! gem_installed ]]; then
    echo 'Installing rubygems'
    apt-get install rubygems || exit 1
fi

if [[ ! rake_installed || ! bundler_installed || ! rails_installed ]]; then
    echo 'Installing rails and bundler and rake gems'
    gem install rails bundler rake || exit 1
fi

if [[ ! git_installed ]]; then
    echo 'Installing git'
    apt-get install git || exit 1
fi


echo 'Cloning the git repository'
git clone git://github.com/matstc/socialite.git || exit 1

echo "Socialite was installed to `pwd`/socialite"
echo "You should now go down into the socialite directory and run the following command (specify your own administrator username and password):"
echo "  rake production:initialize[username,password]"
