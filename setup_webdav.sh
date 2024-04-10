#!/bin/bash

# Define NAS mount point
NAS_MOUNT_POINT="/mnt/ninnie"

# Update system and install Lighttpd
echo "Updating package list and installing Lighttpd..."
sudo apt-get update
sudo apt-get install -y lighttpd

# Enable necessary Lighttpd modules for WebDAV
echo "Enabling required Lighttpd modules..."
sudo lighttpd-enable-mod webdav
sudo lighttpd-enable-mod auth
sudo lighttpd-enable-mod alias

# Create and enable the WebDAV configuration
WEBDAV_CONF="/etc/lighttpd/conf-available/10-webdav.conf"
echo "Configuring WebDAV..."
sudo tee $WEBDAV_CONF > /dev/null <<EOF
server.modules += ( "mod_webdav" )
\$HTTP["url"] =~ "^/webdav($|/)" {
    webdav.activate = "enable"
    webdav.is-readonly = "disable"
    alias.url += ( "/webdav" => "$NAS_MOUNT_POINT" )
}
EOF

# Enable the WebDAV configuration
sudo lighttpd-enable-mod webdav

# Change ownership of the NAS mount point to www-data
echo "Adjusting permissions for the NAS mount point..."
sudo chown -R www-data:www-data $NAS_MOUNT_POINT

# Restart Lighttpd to apply changes
echo "Restarting Lighttpd..."
sudo systemctl restart lighttpd

echo "WebDAV setup complete. Access your NAS content at http://<your-raspberry-pi-ip>/webdav"

