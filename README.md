This is an Ansible playbook to install and configure Foreman and Foreman Smart Proxies. This playbook was designed to be an easy way to get Foreman/Foreman Proxies installed and configured for provisioning.

## Requirements
- FQDN should be used
- CentOS 7.x (I have only tested on CentOS7, selinux disabled)
- SSH key from ansible control node should exist on all hosts in the inventory

## Installation

- Copy group_vars/all.yml.sample to group_vars/all.yml and edit accordingly. The defaults will get a Foreman instance up and running and ready to provision.
- Edit inventory with correct hostnames
- Run playbook. For example, 
    * to install foreman and smart proxy(s): ansible-playbook install.yml
    * to install foreman only: ansible-playbook install-foreman.yml
    * to install add a smart proxy only: ansible-playbook install-foreman.yml

## Notes
The playbook will install a http server to host media. You can use this server for the installation media. When creating installation media, use "media-server" for the hostname. This will use the media server local to the provisioning subnet/isolated network the host is connected to. For instance, in the Path field, use http://media-server:81/media/centos7-1810/

On dual homed smart proxies, set the media_server variable to the isolated network IP address. If the provisioning network is not isolated, just set it to the IP address of the smart proxy.

There is a cron job that runs the script /opt/scripts/sync_media.sh every minute that will check the /opt/iso directory on the foreman server for .iso files and will create the directories (based on the filename), extract the iso and  copy the contents to every smart proxy. All you need to do is copy the .iso file to the foreman server (/opt/iso). You can also add any file or directory to the foreman server (/opt/media-library) and this directory synchronizes with all smart proxies ( accessed at http://media-server:81/media).

This playbook will add an entry in the local hosts on the smart proxy called "smart-proxy". This will resolve to the smart proxys' IP address (look at the inventory sample). You will need to update the discovery scripts and change the proxy.url and proxy.type to the following:

     proxy.url=https://smart-proxy:8443 proxy.type=proxy

This allows the discovered hosts to use the correct proxy.
