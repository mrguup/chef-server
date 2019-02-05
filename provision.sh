#!/usr/bin/env bash
set -e

WORKDIR='/home/chefadmin'
APP_USER='chefadmin'
APP_EMAIL='dm@westmaglabs.com'
APP_DEPENDENCIES=(
    'grep'
    'vim'
    'tree'
)

id -u $APP_USER ||  adduser --system --shell /bin/bash --home $WORKDIR --group $APP_USER

[ ! -d "$WORKDIR" ] && mkdir -p "$WORKDIR" && echo "> Created $WORKDIR"
echo "cd $WORKDIR" > /etc/profile.d/login-directory.sh

if [ ! -f "$WORKDIR/.depinstall.lock" ]; then
    echo "> Updating apt and installing dependencies: [${APP_DEPENDENCIES[@]}]"
    apt-get update
    #apt-get -y upgrade
    apt-get -y install "${APP_DEPENDENCIES[@]}" | tee "$WORKDIR/.depinstall.lock"
else
    echo "> Dependencies already installed. Run 'rm -f $WORKDIR/.depinstall.lock' to force a reinstall on next provision."
fi

cd $WORKDIR
[ ! -f ".pkginstalled" ] && dpkg -i /tmp/chef-server.deb && touch ".pkginstalled"
echo "  - Chef Server is installed"
[ ! -f ".manageinstalled" ] && chef-server-ctl install chef-manage && touch ".manageinstalled"
echo "  - Chef Manager is installed"
[ ! -f ".serverconfigured" ] && chef-server-ctl reconfigure && touch ".serverconfigured"
echo "  - Chef Server is configured"
[ ! -f ".manageconfigured" ] && chef-manage-ctl reconfigure --accept-license && touch ".manageconfigured"
echo "  - Chef Manager is configured"

if [ ! -f "/mnt/shared_files/.adminconfigured" ]; then
    mkdir .chef
    date | base64 | tr -d '\n' > default_password
    touch "/mnt/shared_files/.adminconfigured"
fi

[ ! -f ".userconfigured" ] && chef-server-ctl user-create $APP_USER 'Master' 'Chef' $APP_EMAIL `cat /mnt/shared_files/default_password` --filename /mnt/shared_files/.chef/default.pem && touch ".userconfigured"
[ ! -f ".orgconfigured" ] && chef-server-ctl org-create daa_org "The Secret Clubhouse" --association_user $APP_USER --filename /mnt/shared_files/.chef/default.pem && touch ".orgconfigured"

echo "> Done configuring Chef Server!"
echo "  Access it at 192.168.8.100"
echo "  U: $APP_USER"
echo "  P: `cat /mnt/shared_files/default_password`"
