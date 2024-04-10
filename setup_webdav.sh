#!/bin/bash

# Define your NAS mount point and Lighttpd WebDAV configuration path
NAS_MOUNT_POINT="/mnt/ninnie"
LIGHTTPD_WEBDAV_CONF_PATH="/etc/lighttpd/conf-available/10-webdav.conf"

# Update and install Lighttpd
sudo apt update
sudo apt install -y lighttpd

# Enable Lighttpd modules required for WebDAV
sudo lighttpd-enable-mod webdav
sudo lighttpd-enable-mod auth
sudo lighttpd-enable-mod alias

# Create the WebDAV configuration
echo "server.modules += ( \"mod_webdav\" )
\$HTTP[\"url\"] =~ \"^/webdav($|/)\" {
    webdav.activate = \"enable\"
    webdav.is-readonly = \"disable\"
    alias.url += ( \"/webdav\" => \"$NAS_MOUNT_POINT\" )
}" | sudo tee $LIGHTTPD_WEBDAV_CONF_PATH

# Restart Lighttpd to apply changes
sudo service lighttpd restart

echo "Lighttpd with WebDAV has been set up. Your NAS content is available at http://<your-raspberry-pi-ip>/webdav"
